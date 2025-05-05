# frozen_string_literal: true

module Demoable
  extend ActiveSupport::Concern

  def demo_user
    return @current_user unless @current_user.nil?

    @current_user = User.new( id: -7,
                              first_name: t( :demo_surname_1 ),
                              last_name: t( :demo_fam_name_1 ),
                              timezone: t( :demo_user_tz ) )
  end

  def get_demo_project
    @project = ProjStub.new
    @project.style = Style.find( 2 )
    @project.name = t :demo_project
    @project.description = t :demo_project_description
    @project.factor_pack = FactorPack.find( 4 ).factors # Hard code AECT2023 Factor Pack
    @project
  end

  def get_demo_group
    @group = GroupStub.new
    @group.id = -1
    @group.name = t :demo_group
    user_names = [%w[Doe Robert],
                  %w[Jones Roberta], %w[Kim Janice]]
    @group.users = []
    @group.project = @project

    @group.users << @current_user

    user_names.each_with_index do | name, idx |
      u = User.new( id: -idx, last_name: name[0], first_name: name[1] )
      @group.users << u
    end
    @group
  end

  def get_demo_candidate_list
    cl = CandidateList.new( id: -42,
                            user_id: -11,
                            group_id: nil,
                            is_group: false,
                            bingo_game_id: -42,
                            group_requested: false,
                            archived: false,
                            contributor_count: 1,
                            current_candidate_list: nil,
                            candidates: [] )

    concepts = get_demo_game_concepts
    feedbacks = CandidateFeedback.all.to_a
    rand( 9..10 ).times do | index |
      # select a concept
      term = concepts.delete( concepts.sample )
      concept = term[0]
      definition = term[1]
      term = concept

      feedback = rand( 3 ) < 2 ? feedbacks[0] : feedbacks.sample
      definition = concepts.delete( concepts.sample )[1] if 1 != feedback.id

      cl.candidates << Candidate.new(
        id: - index,
        concept: Concept.new( name: concept ),
        definition:,
        term:,
        candidate_feedback: feedback
      )
    end
    cl.candidates_count = cl.candidates.size
    cl.cached_performance = cl.candidates
                              .reduce( 0 ) { | sum, candidate | sum + candidate.candidate_feedback_credit } / 10
    cl
  end

  def get_demo_bingo_game
    BingoGame.new( id: -11,
                   topic: ( t 'candidate_lists.demo_review_topic' ),
                   description: ( t 'candidate_lists.demo_review_description' ),
                   end_date: Time.zone.today.end_of_day,
                   size: 5,
                   course: Course.new(
                     name: ( t 'demo_course_name' ),
                     number: 'xxx-673'
                   ),
                   individual_count: 10 )
  end

  def get_demo_installment
    a = AssessmentStub.new
    a.id = -1
    a.project = get_demo_project

    i = InstallmentStub.new
    i.id = -42
    i.user_id = -1
    i.assessment = a
    i.assessment_id = a.id
    i.inst_date = DateTime.current.in_time_zone( 'UTC' )
    i
  end

  def get_demo_submission( count )
    s = SubmissionStub.new
    s.id = count
    s.submitted = 72.hours.ago + ( -count * 23 ).hours
    s.withdrawn = nil
    s.sub_text = Faker::Lorem.paragraphs( number: rand( 5 ) )
    s.updated_at = 70.hours.ago + ( -count ).hours
    s.user = demo_user.name( false )
    s.sub_text = Faker::Lorem.paragraphs( number: 5, supplemental: true )
                             .reduce('') do | html_output, paragraph |
      html_output += "<p>#{paragraph}</p>"
    end
    s.sub_link = nil
    s.submission_feedback = get_demo_submission_feedback( count.abs )
    rubric_row_feedbacks = []
    get_demo_rubric_student.criteria.each_with_index do | c, idx |
      rubric_row_feedbacks << get_demo_rubric_row_feedback( c.id, count, c.weight )
    end
    s.rubric_row_feedbacks = rubric_row_feedbacks
    # must actually calculate the score
    s.calculated_score
    s.recorded_score = s.calculated_score + rand( 10 )
    s.group = get_demo_group
    s
  end

  def get_demo_student_assignment
    a = AssignmentStub.new
    a.id = -99
    a.name = t 'assignments.demo.student_title'
    a.description = t 'assignments.demo.student_description'
    a.file_sub = false
    a.link_sub = false
    a.text_sub = true
    a.project = get_demo_project
    a.group_enabled = true
    a.start_date = 2.months.ago
    a.end_date = 5.weeks.from_now.end_of_day
    a.submissions = []
    a.submissions << get_demo_submission( -1 )
    a.submissions << get_demo_submission( -2 )
    a.submissions << get_demo_submission( -3 )
    a.course_timezone = 'UTC'
    a.course = get_demo_course
    a
  end

  def get_demo_instructor_assignment
    a = AssignmentStub.new
    a.id = -99
    a.name = t 'assignments.demo.instructor_title'
    a.description = t 'assignments.demo.instructor_description'
    a.file_sub = false
    a.link_sub = false
    a.text_sub = true
    a.project = get_demo_project
    a.group_enabled = true
    a.start_date = 3.months.ago
    a.end_date = 6.weeks.from_now.end_of_day
    a.submissions = []
    a.submissions << get_demo_submission( -1 )
    a.submissions << get_demo_submission( -2 )
    a.submissions << get_demo_submission( -3 )
    a.course_timezone = 'UTC'
    a.course = get_demo_course
    a
  end

  def get_demo_course
    c = CourseStub.new
    c.id = -1
    c.name = t 'demo_course_name'
    c.number = 'xxx-673'
    c.projects = [get_demo_project]
    c
  end

  def get_demo_rubric_student
    r = RubricStub.new
    r.id = -1
    r.name = t 'rubrics.demo.student_rubric_name'
    r.description = t 'rubrics.demo.student_rubric_description'
    r.version = 1
    r.criteria = []
    # 3 Criteria
    c = CriteriumStub.new
    c.id = -2
    c.description = t 'rubrics.demo.rubric_criteria_1'
    c.weight = 4
    c.sequence = 1
    c.l1_description = t 'rubrics.demo.rubric_criteria_1_level_1'
    c.l2_description = t 'rubrics.demo.rubric_criteria_1_level_2'
    c.l3_description = t 'rubrics.demo.rubric_criteria_1_level_3'
    c.l4_description = ''
    c.l5_description = ''
    r.criteria << c
    c = CriteriumStub.new
    c.id = -3
    c.description = t 'rubrics.demo.rubric_criteria_2'
    c.weight = 4
    c.sequence = 2
    c.l1_description = t 'rubrics.demo.rubric_criteria_2_level_1'
    c.l2_description = t 'rubrics.demo.rubric_criteria_2_level_2'
    c.l3_description = t 'rubrics.demo.rubric_criteria_2_level_3'
    c.l4_description = ''
    c.l5_description = ''
    r.criteria << c
    c = CriteriumStub.new
    c.id = -4
    c.description = t 'rubrics.demo.rubric_criteria_3'
    c.weight = 3
    c.sequence = 3
    c.l1_description = t 'rubrics.demo.rubric_criteria_3_level_1'
    c.l2_description = t 'rubrics.demo.rubric_criteria_3_level_2'
    c.l3_description = ''
    c.l4_description = ''
    c.l5_description = ''
    r.criteria << c
    r
  end

  def get_demo_submission_feedback( index )
    sf = SubmissionFeedbackStub.new
    sf.id = -index
    sf.feedback = t "submissions.feedbacks.demo_feedback_#{index}"
    sf.submitted = Time.zone.now
    sf.rubric_row_feedbacks = []
    get_demo_rubric_student.criteria.each_with_index do | c, idx |
      sf.rubric_row_feedbacks << get_demo_rubric_row_feedback( c.id, index, c.weight )
    end
    sf
  end

  def get_demo_rubric_row_feedback( index, count, weight )
    r = RubricRowFeedbackStub.new
    r.id = -1

    r.score = 44 + (7.5 * (index ^ count.abs ) ).floor
    r.feedback = Faker::ChuckNorris.fact
    r.criterium_id = index
    r.rubric_row_weight = weight
    r.submission_feedback_id = -count
    r
  end

  class InstallmentStub
    attr_accessor :id, :user_id, :assessment, :assessment_id, :group, :group_id, :values, :inst_date

    def values_build( factor:, user:, value: )
      self.values = values || []
      v = Value.new
      v.factor = factor
      v.factor_id = factor.id
      v.user = user
      v.user_id = user.id
      v.value = value
      values << v
    end
  end

  class AssignmentStub
    attr_accessor :id, :name, :description, :submissions,
                  :file_sub, :link_sub, :text_sub, :group_enabled,
                  :start_date, :end_date, :project,
                  :course_timezone, :course
  end

  class SubmissionStub
    attr_accessor :id, :submitted, :withdrawn,
                  :sub_text, :updated_at, :sub_link,
                  :recorded_score,
                  :submission_feedback, :rubric_row_feedbacks,
                  :user, :group
    def calculated_score
      weight_total = rubric_row_feedbacks.reduce( 0 ) do | sum, rubric_row_feedback |
        sum + rubric_row_feedback.rubric_row_weight
      end
      raw_score = rubric_row_feedbacks.reduce( 0 ) do | sum, rubric_row_feedback |
        sum + (rubric_row_feedback.rubric_row_weight) * rubric_row_feedback.score
      end
      raw_score / weight_total
    end
  end

  class SubmissionFeedbackStub
    attr_accessor :id, :feedback, :submitted,
                  :rubric_row_feedbacks
  end

  class RubricRowFeedbackStub
    attr_accessor :id, :score, :feedback, :criterium_id,
                  :rubric_row_weight,
                  :submission_feedback_id
  end

  class AssessmentStub
    attr_accessor :id, :project
  end

  class UserStub
    attr_accessor :id, :first_name, :last_name

    def name( _anonymize )
      "#{last_name}, #{first_name}"
    end
  end

  class RubricStub
    attr_accessor :id, :name, :description, :version,
                  :criteria, :assignment
  end

  class CriteriumStub
    attr_accessor :id, :description, :weight, :sequence,
                  :l1_description, :l2_description,
                  :l3_description, :l4_description,
                  :l5_description
  end

  class CourseStub
    attr_accessor :id, :name, :number, :projects
  end

  class ProjStub
    attr_accessor :id, :style, :name, :description, :factor_pack

    def get_name( _anon )
      name
    end
  end

  class GroupStub
    attr_accessor :id, :name, :users, :project

    def get_name( _anon )
      name
    end
  end

  def get_demo_game_concepts
    [['Fun', 'Enjoying an activity'],
     ['Play', 'engaging in an activity for fun'],
     ['Challenge', 'a task to test abilities'],
     ['Game Mechanics', 'methods to interact with activity state'],
     ['Game Elements', 'mechanisms for interacting with a game'],
     ['Game-based', 'achieving a goal directly through game play'],
     ['Points', 'a measure and record of achievement'],
     ['Badges', 'a visual representation of specific goal achievement'],
     ['Leaderboards', 'public comparative listing of player progress'],
     ['Motivation', 'desire to achieve a goal'],
     ['Feedback', 'received evaluation of performance'],
     ['Progress Tracking', 'monitoring and recording actvity'],
     ['Story', 'an account of events or a narrative'],
     ['Rewards', 'something given to recognize an accomplishment'],
     ['Avatars', 'an icon or image representing a participant'],
     ['Theme', 'the subject or central idea of an experience'],
     ['Autonomy', 'ability to choose one\'s actions'],
     ['Levels', 'your developmental progress in a game'],
     ['Gartner\'s Hype Cycle', 'an analysis of industry trends'],
     ['Game Dynamics', 'The behaviors that emerge from play'],
     ['Social Interaction', 'working with others'],
     ['Learning Gains', 'knowledge or skills gained from an experience'],
     ['Learning Analytics', 'working with data about instructional '\
     'activity'],
     ['Game Design Principles', 'guidelines for crafting playable '\
     'experiences'],
     ['Learning Design', 'organizing content and activities to '\
     'facilitate understanding'],
     ['Gamified Learning', 'using game elements to enhance instruction'],
     ['Gameful', 'supporting game activities'],
     ['Behavior Change', 'when knowledge and skills changes the way '\
     'we live'],
     ['Simulation', 'pretending to be an item or experience'],
     ['Chance', 'likelhood that an event will occur'],
     ['Surprise', 'an event that was unexpected'],
     ['Reliability', 'when an action consistently achieves the same '\
     'outcome'],
     ['Validity', 'accurate interpretation of data'],
     ['Gamified Platform', 'performs a task enhanced by game elements'],
     ['Learner Characteristics', 'knowing what your students know and '\
     'how they\'ll respond'],
     ['Educational Context', 'the environment in which students learn'],
     ['Learning Environment', 'the environment in which students learn'],
     ['Evidence-based', 'relying on collected data'],
     ['Experience Design', 'focusing on the user rather than the technology'],
     ['Competition', 'a contest between two or more people'],
     ['Learner Engagement', 'student involvement in education activies'],
     ['Active Learning', 'when students are involved in the process']]
  end
end
