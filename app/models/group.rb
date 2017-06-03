# frozen_string_literal: true
require 'forgery'
class Group < ActiveRecord::Base
  around_update :track_history
  after_initialize :store_load_state

  belongs_to :project, inverse_of: :groups
  has_and_belongs_to_many :users, inverse_of: :groups
  has_many :group_revisions, inverse_of: :group, dependent: :destroy
  has_many :candidate_lists, inverse_of: :group

  has_many :installments, inverse_of: :group, dependent: :destroy

  validates :name, :project_id, presence: true
  validate :validate_activation_status, on: :update

  before_create :anonymize

  def validate_activation_status
    if project_id_was != project_id
      errors.add(:project,
                 'It is not possible to move a group from one project to another.')
    end
    if changed?
      project.active = false
      project.save
    end
  end

  def get_name(anonymous)
    anonymous ? anon_name : name
  end

  def has_user(user)
    users.where('users.id = ?', user.id).any?
  end

  def users_changed?
    users.select { |u| u.new_record? || u.marked_for_destruction? }.any?
  end

  private

  def store_load_state
    @initial_member_state = ''
    user_ids.each do |user_id|
      @initial_member_state += user_id.to_s + ' '
    end
  end

  # Maintain a history of what has changed
  def track_history
    gr = GroupRevision.new(group: self, members: '')
    gr.name = name_was
    user_ids.each do |user_id|
      gr.members += user_id.to_s + ' '
    end
    i_changed = (changed? || @initial_member_state != gr.members)

    yield # Do that save thing

    gr.save if persisted? && i_changed
  end

  private

  def anonymize
    anon_name = "#{Forgery::Personal.language} #{Forgery::LoremIpsum.characters}s"
  end
end
