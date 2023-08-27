# frozen_string_literal: true

class InstallmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[demo_complete]
  before_action :demo_user, only: %i[demo_complete]

  include Demoable

  def submit_installment
    assessment = Assessment.find(params[:assessment_id])
    @title = t 'installments.title'
    project = assessment.project

    # TODO: Consent Log logic ought to move into a before_action
    consent_log = project.course.get_consent_log user: current_user

    if consent_log.present? && !consent_log.presented?
      redirect_to edit_consent_log_path(consent_form_id: consent_log.consent_form_id)
    else
      group = assessment.group_for_user current_user
      @factors = project.factors
      @installment = Installment.includes(values: %i[factor user], assessment: :project)
                                .where(assessment:,
                                       user: current_user,
                                       group:).first
      if @installment.nil?
        @installment = Installment.new(
          assessment:,
          user: current_user,
          inst_date: DateTime.current.in_time_zone(project.course.timezone),
          group:
        )

        cell_value = Installment::TOTAL_VAL / group.users.size
        group.users.each do |u|
          @factors.each do |b|
            @installment.values.build(factor: b, user: u, value: cell_value)
          end
        end
      end
      submit_helper(
        factors: @factors, group:, installment: @installment
      )
    end
  end

  def submit_helper(factors:, group:, installment:)
    respond_to do |format|
      format.html { render installment.assessment.project.style.filename }

      format.json do
        render json: {
          factors: Hash[ factors.collect do |factor|
                           [factor.id, {
                             id: factor.id,
                             name: factor.name,
                             description: factor.description
                           }]
                         end ],
          group: {
            id: group.id,
            name: group.name,
            users: Hash[ group.users.collect do |member|
                           [member.id, {
                             id: member.id,
                             name: member.name(false)
                           }]
                         end ]
          },
          installment: {
            id: installment.id,
            assessment_id: installment.assessment_id,
            inst_date: installment.inst_date,
            values: installment.values.as_json(only: %i[id factor_id user_id value]),
            project: {
              name: installment.assessment.project.name,
              description: installment.assessment.project.description
            }
          },
          sliderSum: Installment::TOTAL_VAL
        }
      end
    end
  end

  def create
    respond_to do |format|
      format.json do
        installment = nil

        ActiveRecord::Base.transaction do
          installment_hash = params[:installment]
          installment = Installment.new(
            assessment_id: installment_hash[:assessment_id],
            group_id: installment_hash[:group_id],
            user: current_user,
            inst_date: installment_hash[:inst_date],
            comments: installment_hash[:comments]
          )
          installment.save!

          if installment.errors.empty?
            params[:contributions].each_value do |contribution|
              contribution.each do |value|
                installment.values.create!(
                  user_id: value[:userId],
                  factor_id: value[:factorId],
                  value: value[:value]
                )
              end
            end
            installment.reload
            render json: {
              error: false,
              messages: {
                status: t('installments.success')
              },
              installment: {
                id: installment.id,
                assessment_id: installment.assessment_id,
                group_id: installment.group_id,
                comments: installment.comments,
                values: installment.values
                                   .collect do |item|
                          {
                            id: item[:id],
                            user_id: item[:userId],
                            factor_id: item[:factorId],
                            name: item[:name],
                            value: item[:value]
                          }
                        end
              }
            }
          end
        rescue ActiveRecord::RecordInvalid => e
          render json: {
            messages: {
              status: e.message
            },
            error: true
          }
        end
      end
    end
  end

  def update
    id = params[:id].to_i

    respond_to do |format|
      format.html do
        @title = t 'installments.title'
        if id.negative?
          flash[:notice] = t 'installments.demo_success'
          redirect_to root_url
        elsif id.positive?
          @installment = Installment.find(id)
          if @installment.update(i_params)
            notice = t('installments.success')
            redirect_to root_url, notice:
          else
            logger.debug @installment.errors.full_messages unless @installment.errors.empty?
            @group = Group.find(@installment.group)
            @project = @installment.assessment.project
            @factors = @installment.assessment.project.factors
            @project_name = @installment.assessment.project.name
            @members = @group.users
            render @project.style.filename
          end
        else
          @installment = Installment.new(i_params)
          @installment.id = nil
          found = false
          @installment.group.users.each do |user|
            found = true if current_user == user
          end

          if !found
            redirect_to root_url error: (t 'installments.err_not_member')
          elsif @installment.save
            @installment.assessment.project
            flash[:notice] = t 'installments.success'
            redirect_to root_url
          else
            @factors = @installment.assessment.project.factors
            @project_name = @installment.assessment.project.name
            @group = @installment.group

            @members = @installment.values_by_user.keys
            if @installment.errors[:base].any?
              flash[:error] = @installment.errors[:base][0]
              redirect_to root_url
            else
              flash[:error] = t 'installments.err_unknown'
              render @installment.assessment.project.style.filename
            end
          end
        end
      end
      format.json do
        if id.negative?
          render json: {
            messages: {
              status: t('installments.demo_success')
            },
            installment: {
              id:,
              assessment_id: params[:assessment_id],
              group_id: params[:group_id],
              values: params[:contributions].values
                                            .reduce([]) do |tmpArr, itemSet|
                        tmpArr.concat(
                          itemSet.collect do |item|
                            {
                              id: item[:id],
                              user_id: item[:userId],
                              factor_id: item[:factorId],
                              name: item[:name],
                              value: item[:value]
                            }
                          end
                        )
                      end
            }
          }
        else
          ActiveRecord::Base.transaction do
            installment = Installment.includes(:values).find(id)
            installment.comments = params[:installment][:comments]
            installment.save!

            value_hash = installment.values.reduce { |v_map, item| v_map[item.id] = item }
            params[:contributions].each do |contribution|
              value = value_hash[contribution.id]
              if value.nil?
                installment.build_value(
                  user_id: item[:userId],
                  factor_id: item[:factorId],
                  value: item[:value]
                )
              else
                value.value = item[:value]
              end
              # TODO: check for valid sum and normalize if not
              value.save!
            end
          end
          Rails.logger.debug value.errors.full_messages unless value.errors.empty?
          if value.errors.empty?
            render json: {
              messages: {
                status: t('installments.success')
              },
              installment: {
                id:,
                assessment_id: params[:assessment_id],
                group_id: params[:group_id],
                values: params[:contributions].values
                                              .reduce([]) do |tmpArr, itemSet|
                          tmpArr.concat(
                            itemSet.collect do |item|
                              {
                                id: item[:id],
                                user_id: item[:userId],
                                factor_id: item[:factorId],
                                name: item[:name],
                                value: item[:value]
                              }
                            end
                          )
                        end
              }
            }
          else
            render json: {
              messages: value.errors.full_messages,
              error: true
            }

          end
        end
      end
    end
  end

  def demo_complete
    @title = t 'demo_title', orig: t('installments.title')
    @project = get_demo_project
    @group = get_demo_group

    @installment = get_demo_installment
    @installment.group = @group

    @factors = @project.factor_pack
    @members = @group.users

    cell_value = Installment::TOTAL_VAL / @members.size
    @members.each do |_u|
      @factors.each do |b|
        @installment.values_build(factor: b, user: _u, value: cell_value)
      end
    end

    submit_helper(
      factors: @factors, group: @group, installment: @installment
    )
  end

  private

  def i_params
    params.require(:installment).permit(:inst_date, :comments, :group_id, :user_id, :assessment_id, :group_id,
                                        values_attributes: %i[factor_id user_id value])
  end
end
