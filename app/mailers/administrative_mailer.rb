# frozen_string_literal: true

class AdministrativeMailer < ApplicationMailer
  default from: 'support@CoLab.online'
  has_history

  def remind(user)
    @user = user
    headers 'X-SMTPAPI' => {
      category: ['reminder']
    }.to_json

    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: 'CoLab Assessment reminder email')
  end

  def summary_report(name, course_name, user, completion_hash)
    @name = name
    @user = user
    @course_name = course_name
    @completion_report = completion_hash
    headers 'X-SMTPAPI' => {
      category: ['reporting']
    }.to_json

    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: "CoLab: #{@name}")
  end

  def re_invite(user)
    @user = user
    headers 'X-SMTPAPI' => {
      category: ['re-invite']
    }.to_json

    mail(to: user.email.to_s,
         subject: 'Invitation to CoLab')
  end

  def notify_availability(user, activity)
    @user = user
    @activity = activity
    headers 'X-SMTPAPI' => {
      category: ['availability']
    }.to_json

    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: "CoLab: #{activity} is available")
  end

  # Business methods

  def self.inform_instructors
    Assessment.inform_instructors
    Experience.inform_instructors
    BingoGame.inform_instructors
  end

  # Send out email reminders to those who have yet to complete their waiting assessments
  def self.send_reminder_emails
    logger.debug 'Sending reminder emails'
    curr_date = DateTime.current
    finished_users = User.joins(installments: :assessment)
                         .where('assessments.start_date < ? AND assessments.end_date > ?',
                                curr_date, curr_date).to_a

    current_users = User.joins(:rosters, groups: { project: :assessments })
                        .where('assessments.start_date <= ? AND assessments.end_date >= ? AND ' \
                              'projects.active = TRUE AND rosters.role IN (?)',
                               curr_date, curr_date,
                               [Roster.roles[:invited_student],
                                Roster.roles[:enrolled_student]]).to_a

    finished_users.each do |user|
      current_users.delete user
    end

    Experience.active_at(curr_date).each do |experience|
      next unless experience.is_open?

      experience.course.enrolled_students.each do |user|
        reaction = experience.get_user_reaction user
        current_users.push user unless reaction.persisted? && reaction.behavior.present?
      end
    end

    # Make sure all the users are unique
    uniqued = current_users.uniq

    logger.debug '***********************************'
    logger.debug '            Mailing'
    logger.debug '***********************************'
    email_count = 0

    uniqued.each do |u|
      next if !u.last_emailed.nil? && u.last_emailed.today?

      AdministrativeMailer.remind(u).deliver_later

      u.last_emailed = curr_date
      u.save
      logger.debug "Email sent to: #{u.name false} <#{u.email}>"
      email_count += 1
    end

    logger.debug '***********************************'
    logger.debug '             Report'
    logger.debug '***********************************'
    logger.debug "Initiated #{email_count} emails"
  end
end
