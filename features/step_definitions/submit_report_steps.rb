require "forgery"

Given /^the project measures (\d+) factors$/ do |num_factors|
   bp = FactorPack.make
   num_factors.to_i.times do
      bp.factors << Factor.make
   end
   bp.save
   @project.factor_pack = bp
   @project.save
end

Given /^the project started last month and lasts (\d+) weeks, opened yesterday and closes tomorrow$/ do |num_weeks|
   @project.start_date = (Date.today - 1.month)
   @project.end_date = (@assessment.start_date + num_weeks.to_i.weeks)
   @project.start_dow = Date.yesterday.wday
   @project.end_dow = Date.tomorrow.wday
end

When /^the user submits the installment$/ do
   click_link_or_button( "Submit Weekly Installment" )
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

When /^user clicks the link to the project$/ do
   click_link_or_button @project.name
end

Then /^the user should enter values summing to (\d+), "(.*?)" across each column$/ do |column_points,distribution|
   group_installment = @user.waiting_installments[ 0 ]

   if column_points.to_i <= 0
      page.all( :xpath, "//input[starts-with(@id,\"installment_values_attributes_\")]" ).each do |element|
         if element[:id].end_with? "value"
            element.set Random::rand( 3200 ).abs
         end
      end
   elsif distribution == "evenly"
      cell_value = column_points.to_i / group_installment[ 0 ].users.count

      page.all( :xpath, "//input[starts-with(@id,\"installment_values_attributes_\")]" ).each do |element|
         if element[:id].end_with? "value"
            element.set cell_value
         end
      end
   else
      @assessment.factors.each do |factor|
         elements = page.all( :xpath, "//input[contains(@class,\"#{factor.name.delete( ' ' )}\")]" )
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

Then /^the installment form should request factor x user values$/ do
   group_installments = @user.waiting_installments
   group_installments.count.should eq 1
   group = group_installments[ 0 ][ 0 ]
   factors = group_installments[ 0 ][ 1 ].factors

   expected_count = group.users.count * factors.count

   actual_count = 0
   page.all( :xpath, "//input[starts-with(@id,\"installment_values_attributes_\")]" ).each do |element|
      if element[:id].end_with? "value"
         actual_count = actual_count + 1
      end
   end
   actual_count.should eq expected_count
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
   step "the installment form should request factor x user values"
   step "the user should enter values summing to 6000, \"evenly\" across each column"
   step "the user submits the installment"
   step "there should be no error"
end


Then /^the user logs out$/ do
   click_link_or_button( "Logout" )
end

Then /^there should be an error$/ do
   page.should have_content( "The factors in each category must equal 6000." )
end

