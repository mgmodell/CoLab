Rails.application.config.middleware.use OmniAuth::Builder do
   provider :google_oauth2,
      Rails.application.credentials.google.client_id,
      Rails.application.credentials.google.client_key, { }
   #{
   #   :scope => 'email, profile',
   #   :image_aspect_ratio => 'square',
   #   :image_size => 48,
   #   :access_type => 'online'
   #}
end
