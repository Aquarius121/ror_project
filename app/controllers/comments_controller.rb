class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  def index
    route_id = params[:related_id] || params[:route_id]
    if route_id
      route = Route.find(route_id)
      @comments = Comment.for_route(route.id).to_a if can_access_comments?(route, current_user)
    else
      @comments = Comment.all
    end
  end

  def show_for_route
    route = Route.find(params[:related_id])
    @comments = Comment.for_route(route.id).to_a if can_access_comments?(route, current_user)
  end

  def show
    @name = @comment.user.full_name
  end

  def new
    route = Route.find(params[:related_id] || params[:route_id])
    if can_access_comments?(route, current_user)
      @all_comments = Comment.for_route(route.id).to_a
      @comment = Comment.new(:related_id => params[:related_id])
    else
      @comment = false
    end
    render :template => "comments/new", :layout => false
  end

  def edit
  end

  def create
    route = Route.find(comment_params[:related_id])
    if can_access_comments?(route, current_user)
      @comment = current_user.comments.build(comment_params)
      respond_to do |format|
        if @comment.save
          format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
          format.json { render action: 'show', status: :created, location: @comment }
        else
          format.html { redirect_to authenticated_root_path }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.json { render json: {:error => 'error'}, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_url }
      format.json { head :no_content }
    end
  end

  private
  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:route_id, :related_id, :user_id, :body)
  end
end
