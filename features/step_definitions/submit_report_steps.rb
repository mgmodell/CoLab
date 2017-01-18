require "forgery"

Given /^the project measures (\d+) behaviours$/ do |num_behaviours|
   bp = BehaviourPack.make
   num_behaviours.to_i.times do
      bp.behaviours << Behaviour.make
   end
   bp.save
   @project.behaviour_pack = bp
   @project.save
end

Given /^the project started last month and lasts (\d+) weeks, opened yesterday and closes tomorrow$/ do |num_weeks|
   @project.start_date = (Date.today - 1.month)
   @project.end_date = (@assessment.start_date + num_weeks.to_i.weeks)
   @project.start_dow = Date.yesterday.wday
   @project.end_dow = Date.tomorrow.wday
end

When /^the user submits the installment$/ do
   click_link_or_button( "Submit Weekly Report" )
end

When /^the user returns home$/ do
   visit "/"
end

Then /^there should be no error$/ do
   page.should_not have_content( "Unable to reconcile installment values." )
   page.should_not have_content( "assessment has expired" )
end

Then /^the user should see an error indicating that the installment request expired$/ do
   page.should have_content( "assessment has expired" )
end

When /^user clicks the link to the assessment$/ do
   click_link_or_button @assessment.name
end

Then /^the user should enter values summing to (\d+), "(.*?)" across each column$/ do |column_points,distribution|
   group_report = @user.open_group_reports[ 0 ]

   if column_points.to_i <= 0
      page.all( :xpath, "//input[starts-with(@id,\"report_values_attributes_\")]" ).each do |element|
         if element[:id].end_with? "value"
            element.set Random::rand( 3200 ).abs
         end
      end
   elsif distribution == "evenly"
      cell_value = column_points.to_i / group_report[ 0 ].users.count

      page.all( :xpath, "//input[starts-with(@id,\"report_values_attributes_\")]" ).each do |element|
         if element[:id].end_with? "value"
            element.set cell_value
         end
      end
   else
      @assessment.behaviours.each do |behaviour|
         elements = page.all( :xpath, "//input[contains(@class,\"#{behaviour.name.delete( ' ' )}\")]" )
         index = 0
         total = 0
         while( index < ( elements.length - 1) ) do
            what_is_left = column_points.to_i - total
            value = Random::rand( what_is_left )
            elements[ index ].set value
            total += value
            index += 1
         end
         elements[ index ].set (column_points.to_i - total )
      end
   end
end

Then /^the installment form should request behaviour x user values$/ do
   group_reports = @user.open_group_reports
   assert group_reports.count == 1
   group = group_reports[ 0 ][ 0 ]
   behaviours = group_reports[ 0 ][ 1 ].assessment.behaviours

   expected_count = group.users.count * behaviours.count

   actual_count = 0
   page.all( :xpath, "//input[starts-with(@id,\"report_values_attributes_\")]" ).each do |element|
      if element[:id].end_with? "value"
         actual_count = actual_count + 1
      end
   end
   assert actual_count == expected_count
end

Then /^the assessment should show up as completed$/ do

   #Using some cool xpath stuff to check for proper content
   page.should have_xpath( "//a[contains(., '#{@assessment.name}')]/.." ), "No link to assessment"
   page.should have_xpath( "//td[contains(., 'completed')]" ), "No 'completed' message"

end

Then /^the user logs in and submits an installment$/ do
   step "the user \"has\" had demographics requested"
   step "the user logs in"
   step "the user should see a successful login message"
   step "user should see 1 open assessment"
   step "user should see a consent form listed for the open project"
   step "user clicks the link to the assessment"
   step "user will be presented with the installment form"
   step "the installment form should request behaviour x user values"
   step "the user should enter values summing to 600, \"evenly\" across each column"
   step "the user submits the installment"
   step "there should be no error"
end


Then /^the user logs out$/ do
   click_link_or_button( "Logout" )
end

Then /^there should be an error$/ do
   page.should have_content( "The behaviours in each category must equal 600." )
end

