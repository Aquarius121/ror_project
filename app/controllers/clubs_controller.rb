class ClubsController < ApplicationController
  before_action :set_club, only: [:show, :edit, :update, :destroy]

  def index
    @clubs = Club.all
  end

  def show
    @in_club = Member.is_in_club?(@club.id, current_user.id)
    @approved = Member.is_in_club_approved?(@club.id, current_user.id)
    @members = User.eager_load(:members).where(members: {:club_id => @club.id, :active => true})
      .order('RANDOM()')
      .limit(15)
    if @club.is_owner?(current_user)
      @approve_count = Member.approve_count(@club.id)
    else
      @approve_count = 0
    end
    @members_count = User.eager_load(:members).where(members: {:club_id => @club.id, :active => true}).count
    @rides_count = Route.eager_load(:user => :members).where(members: {:club_id => @club.id, :active => true}).count
  end

  def new
    @club = Club.new
  end

  def edit
  end

  def create
    params[:club][:owner_id] = current_user.id
    @club = Club.new(club_params)

    respond_to do |format|
      if @club.save

        @in_club = true
        @member = Member.create(:user_id => current_user.id, :club_id => @club.id, :active => true)
        @members = User.eager_load(:members).where(members: {:club_id => @club.id, :active => true}).order('RANDOM()').limit(15)

        preference = params[:club][:preference]
        preference = [] unless preference.kind_of?(Array)
        preference.map! { |p| p.to_i }

        club_prefs = @club.club_riding_preferences.to_a
        club_prefs.each do |p|
          p.destroy unless preference.include?(p.preference_id)
        end

        preference.each do |p|
          @club.club_riding_preferences.create(:riding_preference_id => p) unless club_prefs.any? { |x| x.preference_id == p }
        end

        format.html { redirect_to @club, notice: 'Club was successfully created.' }
        format.json { render action: 'show', status: :created, location: @club }
      else
        format.html { render action: 'new' }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @club.update(club_params)
        format.html { redirect_to @club, notice: 'Club was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @club.destroy
    respond_to do |format|
      format.html { redirect_to clubs_url }
      format.json { head :no_content }
    end
  end

  def search
    query = Club
    t = Club.arel_table
    if params[:title] != ''
      query = query.where(t[:title].matches("%#{params[:title]}%"))
    end
    if params[:location] != ''
      query = query.where(t[:location].matches("%#{params[:location]}%"))
    end
    # if params[:club_type_id] != ''
    #   query = query.where(t[:club_type_id].eq(params[:club_type_id]))
    # end
    #TODO Rewrite query
    @clubs = query
    .select("clubs.*, count(DISTINCT members.user_id) as users_count, club_types.title as club_type_name, count(DISTINCT routes.id) as routes_count")
    .group("clubs.id, members.club_id, club_types.id")
    .joins(:club_type)
    .joins('LEFT OUTER JOIN "members" ON "members"."club_id" = "clubs"."id" and "members"."active" = TRUE')
    .joins('LEFT OUTER JOIN "routes" ON "members"."user_id" = "routes"."user_id"')
    .limit(100)
    .distinct("clubs.id")
  end


  def logoupload
    logo = Attachment.new(:file => params[:file])
    if logo.valid?
      logo.save
      @status = true
    else
      @status = false
    end
    @url = logo.file.url(:small)
    @logoId = logo.id
  end

  private
  def set_club
    @club = Club.find(params[:id])
  end

  def club_params
    params.require(:club).permit(:title, :logo_id, :description, :location, :privacy_id, :club_type_id, :owner_id)
  end
end
