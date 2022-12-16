Rails.application.config.middleware.use OmniAuth::Builder do
   provider :google_oauth2, 
      '338872466801-q4d7re3gvjtt6jd5gdic4sj98qo5rea7.apps.googleusercontent.com',
      'TBQY1tbbSxcg8aMlNfGd-oJB', {}
   #{
   #   :scope => 'email, profile', 
   #   :image_aspect_ratio => 'square', 
   #   :image_size => 48, 
   #   :access_type => 'online'
   #}
end
