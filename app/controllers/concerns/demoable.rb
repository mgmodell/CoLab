# frozen_string_literal: true

module Demoable
  extend ActiveSupport::Concern

  def demo_user
    return unless @current_user.nil?

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

  class AssessmentStub
    attr_accessor :id, :project
  end

  class UserStub
    attr_accessor :id, :first_name, :last_name

    def name
      "#{last_name}, #{first_name}"
    end
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
