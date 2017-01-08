require 'fileutils'
require 'gpx/import_factory'
require 'gpx/gpx_exporter'
require 'zip'


class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy, :nearby, :download]
  before_action :check_routes_limit, only: [:create]
  authorize_resource :class => false

  #disable layout for json html calls
  layout Proc.new { |controller| controller.request.xhr? ? false : 'manage' }


  def index
    raise ActionController::RoutingError.new('Not Found') unless current_user.role? :admin
    if params[:sort]
      @routes = sort_order(Route.for_index, params[:sort])
    else
      @routes = Route.for_index
    end
  end

  def show
    @images = {}
    @photos = Array.new
    @owner = @route.user_id == current_user.id
    if @route.gallery
      @photos = (@route.gallery.attachments || [])
      @images = @photos.map { |p| {url: p.file(:original)} }
    end
    if can_access_comments?(@route, current_user)
      @comments = Comment.where(:related_id => @route.id).to_a
    else
      @comments = false
    end
    render :template => 'routes/show', :layout => false
  end

  def my_rides
    @my_rides = Route.all_for_user(current_user.id)
  end

  def friend_rides
    @rides = Route.friend_rides(current_user, params[:friend_id])
  end

  def show_my_routes
    @routes = Route.own_for_user(current_user.id).by_ridedate
  end

  def show_own
    @routes = Route.own_for_user(current_user.id).reorder(ridedate: :desc).limit(100).offset(3)
  end

  def upload_img
    route = Route.find(params[:id])
    if (route && route.user == current_user) || current_user.role?(:admin)
      gallery = route.gallery
      unless gallery
        gallery = Gallery.create!(route_id: route.id)
      end
      img = Attachment.new(:gallery_id => gallery.id, :file => params[:file])
      if img.valid?
        img.save
        @status = true
      else
        @status = false
      end
      @url = img.file.url(:thumb)
      @bigUrl = img.file.url(:original)
      @imgId = img.id
    else
      @status = false
    end
  end

  def delete_img
    img = Attachment.find(params[:id])
    if img.route && img.route.user == current_user
      img.destroy
      render json: {status: 'ok'}
    else
      render json: 'Access not granted', status: :unprocessable_entity
    end
  end

  def new
    @route = Route.new
    render :template => 'routes/new', :layout => false
  end

  def edit
    render :template => 'routes/edit', :layout => false
  end

  def copy
    @old_route = Route.find(params[:id])
    @route = @old_route.dup
    @route.user_id = current_user.id
    @route.completed = false
    user = User.find(@old_route.user_id)
    @owner = true
    respond_to do |format|
      if @route.save
        args = {:full_name => current_user.full_name, :route => @old_route}
        Activity.add_activity('activities/template/copy_route', args, current_user.id, @old_route.user_id)
        NotificationMailer.delay.copy_route(user.id, current_user.id, @old_route.id)
        format.html { redirect_to @route, notice: 'Route was successfully copied.' }
        format.json { render action: 'show', status: :created, location: @route }
      else
        format.html { render action: 'new' }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    if !params[:route][:ridedate] || ((DateTime.parse(params[:route][:ridedate]) rescue ArgumentError) == ArgumentError)
      params[:route][:ridedate] = Time.now.strftime('%Y-%m-%d')
    end
    if !current_user.role?(:admin) || params[:route][:ride_type_id].blank?
      params[:route][:ride_type_id] = '1'
    end

    @route = Route.new(route_params)
    @route.user = current_user

    respond_to do |format|
      if @route.save
        format.html { redirect_to @route, notice: 'Route was successfully created.' }
        format.json do
          if params[:user_token]
            render json: {id: @route.id, updated_at: @route.updated_at.to_time.to_i}, status: :created, location: @route
          else
            render action: 'show', status: :created, location: @route
          end
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if !current_user.role?(:admin) || params[:route][:ride_type_id].blank?
      params[:route][:ride_type_id] = '1'
    end
    if ((DateTime.parse(params[:route][:ridedate]) rescue ArgumentError) == ArgumentError)
      params[:route][:ridedate] = Time.now.strftime('%Y-%m-%d')
    end

    if @route.user_id == current_user.id || (current_user.role? :admin)
      respond_to do |format|
        if @route.update(route_params)
          format.html { redirect_to @route, notice: 'Route was successfully updated.' }
          format.json { render action: 'show', status: :created, location: @route }
        else
          format.html { render action: 'edit' }
          format.json { render json: @route.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render action: 'new', notice: 'You must be route owner or an admin to edit this route.' }
        format.json { render json: @route }
      end
    end
  end

  def destroy
    if @route.user_id == current_user.id || (current_user.role? :admin)
      @route.archived = true
      @route.save!
      respond_to do |format|
        format.html { redirect_to routes_url }
        format.json { render json: {route_count_exceeded: current_user.route_count_exceeded?} }
      end
    else
      respond_to do |format|
        format.html { render action: 'new', notice: 'You must be route owner or an admin to delete this route.' }
        format.json { render json: @route }
      end
    end
  end

  def search
    @rides = Route.search(params[:title], params[:location], params[:type], current_user)
  end

  def search_butler
    @rides = current_user.role?(:free) ?
        [] :
        Route.search_butler(params[:title], params[:location], params[:ride_type])
  end

  def g1_markers
    render json: current_user.roles?(:free, :plus) ? [] : Route.g1.to_a.map(&:to_g1_point).compact
  end

  def download
    send_data GpxExporter.export(@route),
              filename: "#{@route.title}.gpx",
              type: 'application/octet-stream',
              x_sendfile: true
  end

  def upload
    route = params[:file]
    filename = route.original_filename
    directory = File.join(Rails.root, "public/system/gpx/#{current_user.id}")
    FileUtils.mkdir_p directory
    path = File.join(directory, filename)
    File.open(path, 'wb') { |f| route.rewind; f.write(route.read); route.rewind; }
    if filename =~ /kmz$/i
      Zip::File.open(route.path) do |zip_file|
        entry = zip_file.find_entry('doc.kml')
        route = entry.get_input_stream
      end
    end
    @routes = Gpx::ImportFactory.processor_for(route).process(route.read, current_user.id)
    render :template => 'routes/show_my_routes'
  end

  def nearby
    render :json => @route.nearby_g1_descriptions
  end

  private

  def check_routes_limit
    if current_user.route_count_exceeded? && request.format == 'application/json'
      render :json => {premium: false, description: 'You have reached free account route count limit.'}
    end
  end

  def set_route
    @route = Route.find(params[:id])
  end

  def route_params
    params.require(:route).permit(:title, :surface_id,
                                  :rating, :elevation, :ridedate, :description,
                                  :privacy_id, :condition_id, :data, :ride_distance, :ride_time,
                                  :ride_type_id, :completed, :encoded_path,
                                  :max_lean, :average_speed, :max_speed,
                                  :gallery_attributes => [:attachments_attributes => [:id, :file]])
  end

  def sort_order(query, sort_by)
    case sort_by
      when 'title'
        return query.order(:title)
      when 'username'
        return query.joins(:user).order('users.lastname, users.firstname')
      when 'date'
        return query.order(:ridedate)
      else
        query.all
    end
  end

end
