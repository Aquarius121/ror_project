json.extract! @comment, :id, :related_id, :user_id, :body, :created_at, :updated_at
json.author current_user.full_name
