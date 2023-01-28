json.extract! rubric, :id, :name, :description, :passing, :version, :published, :parent, :created_at, :updated_at
json.url rubric_url(rubric, format: :json)
