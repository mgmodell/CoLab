# frozen_string_literal: true

class LtiGroupImport
  NRPS_SCOPE = 'https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly'

  def initialize(project)
    @project = project
  end

  def resource_link
    LtiResourceLink.where(course_id: @project.course_id)
                   .where.not(names_roles_url: [nil, ''])
                   .order(updated_at: :desc)
                   .first
  end

  def preview(resource_link)
    token = resource_link.lti_deployment.request_access_token(scopes: [NRPS_SCOPE])
    container = LtiResourceLink.fetch_membership_container(
      resource_link.names_roles_url,
      token.fetch('access_token')
    )
    build_preview(container.fetch('members', []))
  end

  private

  def build_preview(members)
    rosters = @project.course.rosters.enrolled.includes(user: :emails)
    students = rosters.each_with_object({}) do |roster, result|
      user = roster.user
      result[user.id] = {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email
      }
    end
    users_by_email = rosters.each_with_object({}) do |roster, result|
      roster.user.emails.each do |email|
        result[email.email.to_s.downcase] = roster.user
      end
    end

    imported_groups = {}
    members.each do |member|
      user = users_by_email[member['email'].to_s.downcase]
      next unless user

      group = group_for(member)
      next unless group

      group_id, group_name = group
      imported_groups[group_id] ||= {
        id: -(imported_groups.length + 1),
        name: group_name,
        diversity: 0,
        faultline: 0,
        member_count: 0
      }
      id = imported_groups[group_id][:id]
      students[user.id][:group_id] = id
      imported_groups[group_id][:member_count] += 1
    end

    {
      groups: imported_groups.values.index_by { |group| group[:id] },
      students:
    }
  end

  def group_for(member)
    value = member['group'] || member['grouping'] || member['group_name'] || member['group_id']
    value ||= Array(member['groups'] || member['groupings']).first
    return if value.blank?

    if value.is_a?(Hash)
      id = value['id'] || value['group_id'] || value['name'] || value['title']
      name = value['name'] || value['title'] || id
    else
      id = name = value
    end
    return if id.blank?

    [id.to_s, name.to_s]
  end
end
