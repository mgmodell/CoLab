# frozen_string_literal: true

# Controller concern that adds LTI connection management and grade pushing
# to resource controllers (BingoGamesController, ExperiencesController,
# ProjectsController).
#
# Including controllers must define +lti_resource+ as a private method that
# returns the model instance to which the LTI connection is attached.
module LtiGradable
  extend ActiveSupport::Concern

  included do
    before_action :set_lti_resource, only: %i[show_lti_connection
                                               update_lti_connection
                                               push_lti_grades]
  end

  # GET  – return the LTI connection configuration for the activity.
  def show_lti_connection
    connection = @lti_resource.lti_connection || @lti_resource.build_lti_connection
    render json: lti_connection_json( connection )
  end

  # PATCH – create or update the LTI connection configuration.
  def update_lti_connection
    connection = @lti_resource.lti_connection || @lti_resource.build_lti_connection

    if connection.update( lti_connection_params )
      render json: lti_connection_json( connection ).merge( messages: { main: t( 'lti.connection_saved' ) } )
    else
      render json: lti_connection_json( connection ).merge(
        messages: { main: t( 'lti.connection_save_failed' ) }
      ), status: :unprocessable_entity
    end
  end

  # POST – push grades to the LMS for the activity.
  def push_lti_grades
    connection = @lti_resource.lti_connection
    unless connection&.configured?
      render json: { success: false, messages: { main: t( 'lti.not_configured' ) } },
             status: :unprocessable_entity
      return
    end

    scores = grade_scores_for( @lti_resource )
    results = scores.map do | score_entry |
      result = connection.push_score(
        user_id: score_entry[:user_id],
        score_given: score_entry[:score_given],
        score_maximum: score_entry.fetch( :score_maximum, 100 )
      )
      { user_id: score_entry[:user_id], **result }
    end

    failures = results.reject { | r | r[:success] }
    if failures.empty?
      render json: { success: true, messages: { main: t( 'lti.grades_pushed', count: results.size ) } }
    else
      render json: {
        success: false,
        messages: { main: t( 'lti.grades_push_partial', success: results.size - failures.size, failed: failures.size ) }
      }, status: :unprocessable_entity
    end
  end

  private

  def set_lti_resource
    @lti_resource = lti_resource
  end

  # Subclasses must return the JSON representation of the LTI connection.
  def lti_connection_json( connection )
    {
      lti_connection: connection.as_json( only: %i[id line_item_url ags_access_token_url client_id
                                                    deployment_id iss] ),
      configured: connection.configured?
    }
  end

  def lti_connection_params
    params.require( :lti_connection ).permit( :line_item_url, :ags_access_token_url,
                                              :client_id, :deployment_id, :iss )
  end

  # Subclasses must implement this to return an array of score hashes:
  #   [ { user_id: <lti_user_id>, score_given: <numeric>, score_maximum: <numeric> }, ... ]
  def grade_scores_for( _resource )
    raise NotImplementedError, "#{self.class}#grade_scores_for must be implemented"
  end

  # Subclasses must implement this to return the activity record.
  def lti_resource
    raise NotImplementedError, "#{self.class}#lti_resource must be implemented"
  end
end
