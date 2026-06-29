# frozen_string_literal: true

class UserController < ApplicationController
  before_action :authenticate_user!
  before_action :check_auth, only: %i[directory_search]
  before_action :check_admin, except: %i[directory_search]

  def directory_search
    school_id = current_user.admin ? params[:school_id] : current_user.school_id
    search_terms = params[:search_term].split
    emails, non_emails = search_terms.partition { |str| str.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i) }

    search_query = school_id > 0 ? 'school_id = ? AND (' : '('
    if !non_emails.empty? 
      search_query += non_emails.map{ 'LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?' }.join(' OR ' )
    end
    if !emails.empty?
      search_query += ' OR ' unless non_emails.empty?
      search_query += emails.map{ 'LOWER(emails.email) = ?' }.join(' OR ' )
    end

    search_query += ')' 

    search_terms = school_id > 0 ? [school_id] : []
    search_terms += non_emails.flat_map{ |term| ["%#{term.downcase}%", "%#{term.downcase}%"] }
    search_terms.concat( emails.flat_map{ |term| [term.downcase] } )

    found_users = User.joins(:school, :emails)
                      .where(search_query, *search_terms).distinct

    resp_hash = { users: found_users.map{ |u| {
                                                first_name: u.first_name,
                                                last_name: u.last_name,
                                                email: u.email,
                                                school_id: u.school_id,
                                                status: u.active
                                                } } }

    respond_to do | format |
      format.json { render json: resp_hash }
    end
  end

  def delete_user
    resp_hash = {}
    user = User.find_by( email: params[:email] )
    if user.nil?
      resp_hash[:success] = false
      resp_hash[:errors] = ["User not found"]
    else  
      user.active = params[:delete] != 'true'
      user.save

      resp_hash[:success] = user.errors.empty?
      resp_hash[:errors] = user.errors.full_messages unless user.errors.empty?
    end

    render json: resp_hash

  end

  def merge_users
    resp_hash = {}
    predator = User.find_by( email: params[:predator_email] )
    prey = User.find_by( email: params[:prey_email] )
    result = User.merge_users( predator: predator, prey: prey )

    render json: resp_hash

  end

  def set_role
    resp_hash = {}
    user = User.find_by( email: params[:email] )
    if user.nil?
      resp_hash[:success] = false
      resp_hash[:errors] = ["User not found"]
    else  
      case params[:role] 
      when 'admin'
        user.admin = params[:set] == 'true'
        user.save
        resp_hash[:success] = user.errors.empty?
        resp_hash[:errors] = user.errors.full_messages unless user.errors.empty?
      when 'instructor'
        user.is_instructor = params[:set] == 'true'
        user.save
        resp_hash[:success] = user.errors.empty?
        resp_hash[:errors] = user.errors.full_messages unless user.errors.empty?
      when 'researcher'
        user.researcher = params[:set] == 'true'
        user.save
        resp_hash[:success] = user.errors.empty?
        resp_hash[:errors] = user.errors.full_messages unless user.errors.empty?
      else
        resp_hash[:success] = false
        resp_hash[:errors] = I18n.t( 'invalid_role' )
      end
    end

    render json: resp_hash

  end

  private
  def check_auth
    unless current_user.is_admin? || current_user.is_instructor? || current_user.researcher
      render json: { error: I18n.t( 'not_authorized') }, status: :unauthorized
    end
  end

  def check_admin
    unless current_user.is_admin?
      render json: { error: I18n.t( 'not_authorized') }, status: :unauthorized
    end
  end
end
