# frozen_string_literal: true

class Concept < ApplicationRecord
  has_many :candidates, inverse_of: :concept
  has_many :candidate_lists, through: :candidates
  has_many :bingo_games, through: :candidate_lists
  has_many :courses, through: :bingo_games

  def self.get_concepts_for_game_demo
    [['Fun', 'Enjoying an activity'],
     ['Play',  'engaging in an activity for fun'],
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
     ['Learning Analytics', 'working with data about instructional
     activity'],
     ['Game Design Principles', 'guidelines for crafting playable
     experiences'],
     ['Learning Design', 'organizing content and activities to
     facilitate understanding'],
     ['Gamified Learning', 'using game elements to enhance instruction'],
     ['Gameful', 'supporting game activities'],
     ['Behavior Change', 'when knowledge and skills changes the way we
     live'],
     ['Simulation', 'pretending to be an item or experience'],
     ['Chance', 'likelhood that an event will occur'],
     ['Surprise', 'an event that was unexpected'],
     ['Reliability', 'when an action consistently achieves the same
     outcome'],
     ['Validity', 'accurate interpretation of data'],
     ['Gamified Platform', 'performs a task enhanced by game elements'],
     ['Learner Characteristics', 'knowing what your students know and
     how they\'ll respond'],
     ['Educational Context', 'the environment in which students learn'],
     ['Learning Environment', 'the environment in which students learn'],
     ['Evidence-based', 'relying on collected data'],
     ['Experience Design', 'focusing on the user rather than the technology'],
     ['Competition', 'a contest between two or more people'],
     ['Learner Engagement', 'student involvement in education activies'],
     ['Active Learning' 'when students are involved in the process']
     ]
  end
end
