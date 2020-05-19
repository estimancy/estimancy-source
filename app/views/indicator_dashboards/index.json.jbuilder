json.array!(@indicator_dashboards) do |indicator_dashboard|
  json.extract! indicator_dashboard, :id, :organization_id, :name, :description
  json.url indicator_dashboard_url(indicator_dashboard, format: :json)
end
