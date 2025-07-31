class CommentsController < ApplicationController
    before_action :authenticate_request!
    before_action :set_commentable # Determines if it's a Project or Task
    before_action :authorize_commentable_access # Ensure user can access the project/task
    before_action :set_comment, only: [:update, :destroy]
    before_action :authorize_comment_modification, only: [:update, :destroy] # Only author or owner can modify
  
    # GET /projects/:project_id/comments OR /tasks/:task_id/comments
    def index
      @comments = @commentable.comments.includes(:user).order(created_at: :asc)
      render json: @comments, include: [:user]
    end
  
    # POST /projects/:project_id/comments OR /tasks/:task_id/comments
    def create
      @comment = @commentable.comments.build(comment_params)
      @comment.user = current_user # Set the current_user as the comment's author
  
      if @comment.save
        render json: @comment, status: :created, include: [:user]
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /comments/:id (or nested if you prefer)
    def update
      if @comment.update(comment_params)
        render json: @comment, include: [:user]
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /comments/:id (or nested if you prefer)
    def destroy
      @comment.destroy
      head :no_content
    end
  
    private
  
    # This method determines if the commentable is a Project or a Task
    def set_commentable
      if params[:project_id]
        @commentable = Project.find(params[:project_id])
      elsif params[:task_id]
        @commentable = Task.find(params[:task_id])
      else
        # If no project_id or task_id, and it's update/destroy for a specific comment, find from comment
        if params[:id] && action_name.in?(['update', 'destroy'])
          comment = Comment.find(params[:id])
          @commentable = comment.commentable
        else
          render json: { error: 'Commentable type not specified.' }, status: :bad_request
        end
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Commentable not found.' }, status: :not_found
    end
  
    # Authorization for reading/creating comments
    def authorize_commentable_access
      project = @commentable.is_a?(Project) ? @commentable : @commentable.project
      unless current_user.member_of_project?(project) || current_user.owns_project?(project)
        render json: { error: 'You are not authorized to comment on this item.' }, status: :forbidden
      end
    end
  
    # Authorization for updating/deleting specific comments
    def authorize_comment_modification
      # User can modify their own comments
      return if @comment.user == current_user
  
      # Project owner can modify/delete any comment within their project
      project = @comment.commentable.is_a?(Project) ? @comment.commentable : @comment.commentable.project
      unless current_user.owns_project?(project)
        render json: { error: 'You are not authorized to modify this comment.' }, status: :forbidden
      end
    end
  
    def set_comment
      @comment = Comment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Comment not found.' }, status: :not_found
    end
  
    def comment_params
      params.require(:comment).permit(:content)
    end
end