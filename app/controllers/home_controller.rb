class HomeController < ApplicationController
   def index
      @current_user = current_user
      #The first thing we want to do is make sure they've had an opportunity to 
      # complete any waiting consent forms
      waiting_consent_logs = @current_user.waiting_consent_logs
      if waiting_consent_logs.count > 0
         redirect_to( :controller => "consent_logs",
         :action => 'edit',
         :consent_form_id => waiting_consent_logs[0].consent_form_id )
      elsif not current_user.welcomed?
         redirect_to edit_user_registration_path(@current_user)
      end
      @first_name = current_user.first_name
      @open_group_reports = current_user.open_group_reports
   end

end
