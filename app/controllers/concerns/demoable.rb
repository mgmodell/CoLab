module Demoable 
  extend ActiveSupport::Concern

  def demo_user
    if @current_user.nil?
      @current_user = User.new(first_name: t(:demo_surname_1),
                               last_name: t(:demo_fam_name_1),
                               timezone: t(:demo_user_tz))
    end
  end
end
