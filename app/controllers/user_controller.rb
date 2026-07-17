# frozen_string_literal: true

class UserController < ApplicationController
  before_action :authenticate_user!
  before_action :check_auth, only: %i[directory_search get_user_details]
  before_action :check_admin, except: %i[directory_search get_user_details]

  def directory_search
    school_id = current_user.is_admin? ? params[:school_id] : current_user.school_id
    search_terms = params[:search_term].split
    joins_fields = []
    emails, non_emails = search_terms.partition { | str | str.match?( /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i ) }

    if current_user.is_admin? || current_user.is_instructor? || !non_emails.empty?
      if school_id > 0 && ( current_user.is_instructor? || current_user.is_admin? )
        joins_fields << :school
        search_query = 'school_id = ? AND ('
      else
        search_query = '('
      end

      unless non_emails.empty?
        search_query += if current_user.is_researcher?
                          non_emails.map do
                            'LOWER(anon_first_name) LIKE ? OR LOWER(anon_last_name) LIKE ?'
                          end.join( ' OR ' )
                        else
                          non_emails.map { 'LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?' }.join( ' OR ' )
                        end
      end
      if !emails.empty? && (current_user.is_admin? || current_user.is_instructor?)
        search_query += ' OR ' unless non_emails.empty?
        search_query += emails.map { 'LOWER(emails.email) = ?' }.join( ' OR ' )
        joins_fields << :emails
      end

      search_query += ') AND users.id != ?'

      search_terms = school_id > 0 && ( current_user.is_instructor? || current_user.is_admin? ) ? [school_id] : []
      search_terms += non_emails.flat_map { | term | ["%#{term.downcase}%", "%#{term.downcase}%"] }
      search_terms.concat( emails.flat_map { | term | [term.downcase] } ) unless current_user.is_researcher?
      search_terms << current_user.id

      # joins_fields = [:school, :emails]
      found_users = if joins_fields.size > 0
                      User.joins( *joins_fields )
                        .where( search_query, *search_terms ).distinct
                    else
                      User.where( search_query, *search_terms ).distinct
                    end

      resp_hash = { users: found_users.map do | u |
        {
          first_name: u.first_name,
          last_name: u.last_name,
          email: current_user.is_researcher? ? u.emails.sample.id : u.email,
          school_id: u.school_id,
          status: u.active,
          is_researcher: u.is_researcher?,
          is_instructor: u.is_instructor?,
          has_classes: u.rosters.instructor.any?,
          is_admin: u.is_admin?
        }
      end }
    end

    respond_to do | format |
      format.json { render json: resp_hash }
    end
  end

  def delete_user
    resp_hash = {}
    user = User.find_by_email( params[:email] )
    if user.nil?
      resp_hash[:success] = false
      resp_hash[:errors] = ['User not found']
    else
      user.active = ! params[:delete] 
      user.save

      resp_hash[:success] = user.errors.empty?
      resp_hash[:errors] = user.errors.full_messages unless user.errors.empty?
    end

    render json: resp_hash
  end

  def merge_users
    resp_hash = {}
    predator = params[:predator_email]
    prey = params[:prey_email]
    result = User.merge_users( predator: predator, prey: prey )

    render json: result
  end

  def set_role
    resp_hash = {}
    user = User.find_by_email( params[:email] )
    if user.nil?
      resp_hash[:success] = false
      resp_hash[:errors] = ['User not found']
    else
      case params[:role]
      when 'admin'
        user.admin = params[:set]
        user.save
        resp_hash[:success] = user.errors.empty?
        resp_hash[:errors] = user.errors.full_messages unless user.errors.empty?
      when 'instructor'
        user.instructor = params[:set]
        user.save
        resp_hash[:success] = user.errors.empty?
        resp_hash[:errors] = user.errors.full_messages unless user.errors.empty?
      when 'researcher'
        user.researcher = params[:set]
        user.save
        resp_hash[:success] = user.errors.empty?
        resp_hash[:errors] = user.errors.full_messages unless user.errors.empty?
        user.reload
      else
        resp_hash[:success] = false
        resp_hash[:errors] = I18n.t( 'invalid_role' )
      end
    end

    render json: resp_hash
  end

  def get_user_details
    resp_hash = {}
    anonymized = current_user.is_researcher?
    user = if current_user.is_instructor? || current_user.is_admin?
             User.find_by_email( params[:email] )
           else
             Email.find_by_id( params[:email] ).user
           end

    if user.nil?
      resp_hash[:success] = false
      resp_hash[:errors] = ['User not found']
    else
      resp_hash[:success] = true
      resp_hash[:user] = {
        first_name: user.get_first_name( anonymized ),
        last_name: user.get_last_name( anonymized ),
        email: anonymized ? '*******' : user.email,
        school: user.get_school_name( anonymized ),
        status: user.active,
        roles: {
          is_instructor: user.is_instructor?,
          is_researcher: user.is_researcher?,
          is_admin: user.is_admin?
        },
        courses: user.rosters.map do | r |
          {
            course_name: user.is_admin? || user.is_instructor? ? r.course.name : r.course.get_name( anonymized ),
            course_number: user.is_admin? || user.is_instructor? ? r.course.number : r.course.get_number( anonymized )
          }
        end
      }
    end
    render json: resp_hash
  end

  private

  def check_auth
    return if current_user.is_admin? || current_user.is_instructor? || current_user.is_researcher?

    render json: { error: I18n.t( 'not_authorized' ) }, status: :unauthorized
  end

  def check_admin
    return if current_user.is_admin?

    render json: { error: I18n.t( 'not_authorized' ) }, status: :unauthorized
  end
end
