json.array!(@livrables) do |livrable|
  json.extract! livrable, :id, :name, :description, :state, :organization_id
  json.url livrable_url(livrable, format: :json)
end
