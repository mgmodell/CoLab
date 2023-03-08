require 'chronic'

    Given('the course has an assignment named {string} with an {string} rubric named {string}') do |assignment_name, rubric_published, rubric_name|
        @rubric = @user.rubrics.new(
            name: rubric_name,
            description: Faker::GreekPhilosophers.quote,
            school: @user.school,
            published: 'published' == rubric_published
        )
        @rubric.criteria.new(
          description: Faker::Company.industry,
          sequence: 1,
          l1_description: Faker::Company.bs
        )
        @rubric.save
        log @rubric.errors.full_messages if @rubric.errors.present?

        @assignment = @course.assignments.new(
            name: assignment_name,
            description: Faker::Quote.yoda,
            passing: 65,
            start_date:  4.months.ago ,
            end_date:  2.months.from_now ,
            rubric: @rubric
        )
        @assignment.save
        log @assignment.errors.full_messages if @assignment.errors.present?
    end
    
    Given('the assignment opening is {string} and close is {string}') do |start_date_string, end_date_string|
        @assignment.start_date = Chronic.parse(start_date_string)
        @assignment.end_date = Chronic.parse(end_date_string)

        @assignment.save
        log @assignment.errors.full_messages if @assignment.errors.present?
    end

    Then('the assignment rubric is {string}') do |rubric_name|
      @assignment.rubric.name.should eq rubric_name
    end
    
    Then('the user sets the assignment {string} to {string}') do |field_name, value|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('retrieve the {string} assignment from the db') do |string|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the assignment {string} field is {string}') do |field_name, value|
      case field_name.downcase
      when 'name'
        @assignment.name.should be value
      when 'description'
        @assignment.description.should be value
      when 'opening'
        @assignment.start_date.should be Chronic.parse(value)
      when 'close'
        @assignment.end_date.should be Chronic.parse(value)
      else
        true.should be false
      end
    end
    
    Then('the assignment {string} active') do |is_active|
      @assignment.is_active.should eq ( 'is' == is_active)
    end
    
    Then('the assignment {string} group capable') do |is_group_enabled|
      @assignment.group_option.should eq ( 'is' == is_group_enabled)
    end
    
    Then('the user sets the assignment project to the course project') do
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the assignment project is the course project') do
      @assignment.project.should be @course.project
    end
    
    Then('the user sets the assignment rubric to {string}') do |string|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Given('the course has an assignment') do
        @assignment = @course.assignments.new(
            name: assignment_name,
            description: Faker::Quote.yoda,
            passing: 65,
            start_date:  4.months.ago ,
            end_date:  2.months.from_now ,
            rubric: nil
        )
    end
    
    Given('the assignment {string} group-capable') do |string|
      @assessment.group_enabled.should be true
    end
    
    Given('the assignment {string} active') do |active_assertion|
      @assignment.active.should eq (active_assertion == 'is' )
    end