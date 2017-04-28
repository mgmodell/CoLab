# frozen_string_literal: true
class AdministrativeMailer < ActionMailer::Base
  default from: 'support@CoLab.online'

  def remind(user)
    @user = user
    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: 'CoLab Assessment reminder email',
         tag: 'reminder',
         track_opens: 'true')
  end

  def summary_report(name, course_name, user, completion_hash)
    @name = name
    @user = user
    @course_name = course_name
    @completion_report = completion_hash
    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
         subject: "CoLab: #{@name}",
         tag: 'reporting',
         track_opens: 'true')
  end

  def re_invite(user)
    @user = user
    mail(to: user.email.to_s,
         subject: 'Invitation to CoLab',
         tag: 're-invite',
         track_opens: 'true')
  end

  def notify_availability( user, activity )
    @user = user
    @activity = activity
    mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
          subject: "CoLab: #{activity} is available",
          tag: 'availability',
          track_opens: 'true' )
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
    finished_users = User.joins(installments: :assessment)
                         .where('assessments.start_date < ? AND assessments.end_date > ?',
                                DateTime.current, DateTime.current).to_a

    current_users = User.joins(groups: { project: :assessments }, rosters: :role)
                        .where('assessments.start_date <= ? AND assessments.end_date >= ? AND ( ' \
                              'roles.name = "Invited Student" OR roles.name = "Enrolled Student" ) ',
                               DateTime.current, DateTime.current).to_a

    finished_users.each do |user|
      current_users.delete user
    end

    Experience.still_open.each do |experience|
      experience.course.enrolled_students.each do |user|
        reaction = experience.get_user_reaction user
        unless reaction.persisted? && reaction.behavior.present?
          current_users.push user
        end
      end
    end

    # Make sure all the users are unique
    uniqued = {}
    current_users.each do |u|
      uniqued[u] = 1
    end

    logger.debug '***********************************'
    logger.debug '            Mailing'
    logger.debug '***********************************'
    email_count = 0

    uniqued.keys.each do |u|
      next if !u.last_emailed.nil? && u.last_emailed.today?
      AdministrativeMailer.remind(u).deliver_later
      u.last_emailed = DateTime.current
      u.save
      logger.debug "Email sent to: #{u.name} <#{u.email}>"
      email_count += 1
    end

    logger.debug '***********************************'
    logger.debug '             Report'
    logger.debug '***********************************'
    logger.debug "Initiated #{email_count} emails"
  end
end
