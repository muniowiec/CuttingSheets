json.extract! ordersheet, :id, :amount, :height, :width, :created_at, :updated_at
json.url ordersheet_url(ordersheet, format: :json)
