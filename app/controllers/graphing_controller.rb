class GraphingController < ApplicationController
   Unit_To_Processing = [ [ "Individual", [ "Summary", "Summary By Behaviour", "All Data" ] ],
      [ "Group",  [ "Summary" ] ],
      [ "Raw Data", [ "Comments" ] ]
   ]

   #Support the app by providing the subject instances
   def subjects
      unit_of_analysis = params[ :unit_of_analysis ]
      assessment_id = params[ :assessment_id ]
      for_research = params[ :for_research ] == "true" ? true : false

      @subjects = []
      case unit_of_analysis
      when "Individual" or "Raw Data"
         if for_research
            @subjects = User.joins( :consent_logs, :assessments ).
              where( :consent_logs => { :accepted => true }, :assessments => { :id => assessment_id } ).
              collect{ |user| [user.name, user.id] }
         else
            @subjects = Assessment.find( assessment_id ).users.collect{ |user| [user.name, user.id] }
         end
      when "Group"
         @subjects = Assessment.find( assessment_id ).groups.collect{ |group| [group.name, group.id] }

      end
      # Return the retrieved data
      respond_to do |format|
         format.json
      end
   end

   # Retrieve all the reported values relating to the
   # specified user and hash them up by Weekly.
   def pull_and_organise_user_data( user_id, assessment_id, for_research = false )
      values = [ ]
      if for_research
         values = Value.includes( :user, :behaviour, :report => [ :weekly, :user ] ).
         joins( :user => { :consent_logs => { :consent_form => :assessments } },
                :report => { :weekly => :assessment } ).
         where( :consent_logs => { :accepted => true },
                                   :user_id => user_id,
                                   :reports => { :user_id => User.consented_to_assessment( assessment_id ) },
                                   :assessments => {:id => assessment_id } )
      else
         values = Value.includes( :user, :behaviour, :report => [ :weekly, :user ] ).
         joins( :report => { :weekly => :assessment } ).
         where( :user_id => user_id, :assessments => { :id => assessment_id } )
      end

      weekly_to_values = Hash.new
      values.each do |value|
         if weekly_to_values[ value.report.weekly ].nil?
            weekly_to_values[ value.report.weekly ] = [ value ]
         else
            weekly_to_values[ value.report.weekly ] << value
         end
      end
      return weekly_to_values

   end

   def individual_summary_data( user, assessment_id, for_research = false )
      weekly_to_values = pull_and_organise_user_data( user.id, assessment_id, for_research )
      data = [ ]
      sequential = weekly_to_values.keys.sort{|a,b| a.start_date <=> b.start_date}
      sequential.each do |weekly|
         values = weekly_to_values[ weekly ]
         data << [ values[ 0 ].created_at.to_i * 1000,
         values.inject( 0 ){ |sum, value| sum + value.value }.to_f / values.size ]
      end
      series = Hash.new
      series.store( "data", data )
      series.store( "label", user.name )
      return series
   end

   # The graphing data is provided as a JSON object containing:
   # data_series
   #   data - an array of [date, value] arrays.
   #   label - name for the series represented by 'data'
   # detail_hash - any relevant data to be dispayed with the set
   # of series.
   def data
      unit_of_analysis = params[ :unit_of_analysis ]
      data_processing = params[ :data_processing ]
      assessment = params[ :assessment ]
      subject = params[ :subject ]
      for_research = params[ :for_research ] == "true" ? true : false

      #TODO - validate that the user has access to the requested data
      @data_series = [ ]
      @detail_hash = Hash.new
      if current_user.is_admin? ||
         Roster.instructorships.where( :user_id => current_user.id, :assessment_id => assessment.to_i )
         # Retrieve the requested data
         case unit_of_analysis
         when "Individual"
            user = User.confirmed.find( subject.to_i )
            @detail_hash.store( "name", user.name )

            case data_processing
            when "Summary"
               series = individual_summary_data( user, assessment.to_i )
               @data_series << series
            when "All Data"
               weekly_to_values = pull_and_organise_user_data( user.id, assessment.to_i, for_research )
               data_hash = Hash.new
               sequential = weekly_to_values.keys.sort{|a,b| a.start_date <=> b.start_date}
               sequential.each do |weekly|
                  values = weekly_to_values[ weekly ]
                  values.each do |value|
                     series = data_hash[ value.behaviour.id.to_s + "_" + value.report.user_id.to_s ]
                     if series.nil?
                        series = Hash.new
                        series.store( "label", value.behaviour.name + " by " + value.report.user.name )
                     end
                     series_data = series[ "data" ]
                     if series_data.nil?
                        series_data = [ ]
                     end
                     series_data << [ value.created_at.to_i * 1000, value.value ]
                     series.store( "data", series_data )
                     data_hash.store( value.behaviour.id.to_s + "_" + value.report.user_id.to_s, series )
                  end
               end
               @data_series = data_hash.values
            when "Summary By Behaviour"
               weekly_to_values = pull_and_organise_user_data( user.id, assessment.to_i, for_research )
               data_hash = Hash.new
               # Begin by sorting by date to group all the categories properly
               sequential = weekly_to_values.keys.sort{|a,b| a.start_date <=> b.start_date}
               sequential.each do |weekly|
                  values = weekly_to_values[ weekly ]
                  values.each do |value|
                     series = data_hash[ value.behaviour.id.to_s ]
                     if series.nil?
                        series = Hash.new
                        series.store( "label", value.behaviour.name )
                     end
                     series_data = series[ "data" ]
                     if series_data.nil?
                        series_data = [ ]
                     end
                     series_data << [ value.report.weekly.start_date.to_time.to_i * 1000, value.value ]

                     #collapsed_series_data << [ date, tmp.inject{|sum,el| sum + el[1] }.to_f / tmp.size ]
                     series.store( "data", series_data )
                     data_hash.store( value.behaviour.id.to_s, series )
                  end
               end
               data_hash.each_pair do |key,value|
                  tmp = [ ]
                  date = value[ "data" ][ 0 ][ 0 ]
                  new_collapsed_data = [ ]
                  value["data"].each do |v|
                     if v[ 0 ] != date
                        new_collapsed_data << [ date, tmp.inject{|sum,el| sum + el}.to_f / tmp.size ]
                        date = v[ 0 ]
                        tmp = [ ]
                     end
                     tmp << v[ 1 ]
                  end
                  value[ "data" ] = new_collapsed_data

               end
               @data_series = data_hash.values
            end
         when "Group"
            group = Group.find( subject.to_i )
            @detail_hash.store( "name", group.name )

            case data_processing
            when "Summary"
               group.users.each do |user|
                  @data_series << individual_summary_data( user, assessment.to_i )
               end
            end
         when "Raw Data"
            user = User.confirmed.find( subject.to_i )
            @detail_hash.store( "name", user.name )

            case data_processing
            when "Comments"
              reports = Report.joins( :weekly ).
                where( :user_id => subject.to_i, weekly: { assessment_id: assessment.to_i } )
              @data = reports
              respond_to do |format|
                format.csv do
                  headers['Content-Disposition'] = "attachment; filename=\"#{user.last_name}_#{user.first_name}.csv\""
                  headers['Content-Type'] ||= 'text/csv'
                end
              end
            end
         end
      else
         @data_series = { "label" => "Restricted", "data" => [] }
         @detail_hash.store( "name", "Restricted: You do not have permission to access this data" )
      end

      # Other stuff here

      # Return the retrieved data
      respond_to do |format|
         format.json
      end
   end

   def index
      @user = current_user
      @current_users_assessments = [ ]

      #Get the assessments administered by the current user
      if @user.is_instructor?
         if @user.is_admin?
            @current_users_assessments = Assessment.all
         elsif @user.is_instructor?
            Roster.instructorships.where( :user_id => @user.id ).each do |roster|
               roster.course.projects.each do |project|
                  if !project.assessment.nil?
                     @current_users_assessments << project.assessment
                  end
               end
            end
         end
         @current_users_assessments.each do |assessment|
         end
      else
         redirect_to root_url
      end
   end

   /*
    Sometimes you want the raw data to play with yourself.
    */
   def raw_data

      user = User.find( subject.to_i )

      reports = Report.joins( :weekly ).
        where( :user_id => subject.to_i, weekly: { assessment_id: assessment.to_i } )
      @data = reports
      respond_to do |format|
        format.csv do
          headers['Content-Disposition'] = "attachment; filename=\"#{user.last_name}_#{user.first_name}.csv\""
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    

   end
end
