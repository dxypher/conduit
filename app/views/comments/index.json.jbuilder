json.comments do |json|
	json.array! @comments, partial: 'comments/comment', as: :comment
end