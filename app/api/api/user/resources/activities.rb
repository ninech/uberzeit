API::Shared::Validators::Includes

class API::User::Resources::Activities < Grape::API
  resource :activities do

    before do
      @activities = Activity.scoped
      @activities = @activities.includes(:activity_type)
      @activities = @activities.includes(params[:embed]) if params[:embed]
    end

    desc 'Lists all activities'
    params do
      optional :embed, type: Array, includes: %w[user project]
    end
    get do
      present @activities, with: API::User::Entities::Activity, embed: params[:embed]
    end

    desc 'Deletes an activity'
    params do
      requires :id, type: Integer, desc: 'Activity ID.'
      optional :embed, type: Array, includes: %w[user project]
    end
    delete ':id' do
      activity = Activity.find params[:id]
      if current_ability.can?(:destroy, activity) && activity.destroy
        present activity, with: API::User::Entities::Activity, embed: params[:embed]
      else
        raise CanCan::AccessDenied
      end
    end

    desc 'Creates an activity.'
    params do
      requires :activity_type_id, type: Integer
      requires :date, type: Date
      requires :duration, type: Integer, desc: 'Activity duration in seconds'
      requires :customer_id, type: Integer
      optional :description, type: String
      optional :project_id, type: Integer
      optional :redmine_ticket_id, type: Integer
      optional :otrs_ticket_id, type: Integer
      optional :billable, type: Boolean, desc: 'Mark as billable'

      optional :embed, type: Array, includes: %w[user project]
    end
    post do

      activity = Activity.create!(
        activity_type_id: params[:activity_type_id],
        date: params[:date],
        duration: params[:duration],
        description: params[:description],
        customer_id: params[:customer_id],
        project_id: params[:project_id],
        redmine_ticket_id: params[:redmine_ticket_id],
        otrs_ticket_id: params[:otrs_ticket_id],
        user_id: current_user.id,
        billable: !!params[:billable]
      )
      present activity, with: API::User::Entities::Activity, embed: params[:embed]
    end

    namespace :redmine_ticket do
      desc 'Retrieves all activities associated with the supplied redmine ticket id'
      params do
        requires :redmine_ticket_id
      end
      get ':redmine_ticket_id' do
        present @activities.by_redmine_ticket(params[:redmine_ticket_id]), with: API::User::Entities::Activity, embed: params[:embed]
      end
    end

    namespace :otrs_ticket do
      desc 'Retrieves all activities associated with the supplied orts ticket id'
      params do
        requires :otrs_ticket_id
      end
      get ':otrs_ticket_id' do
        present @activities.by_otrs_ticket(params[:otrs_ticket_id]), with: API::User::Entities::Activity, embed: params[:embed]
      end
    end

    # This is NOT THE PROPER SOLUTION
    # We have yet to define how we implement pagination in the future in our APIs
    # see redmine #7606
    namespace :latest do
      desc 'Retrieves the latest updated/created activity by the current user'
      get do
        present @activities.unscoped
                           .where(user_id: current_user.id)
                           .order('updated_at DESC')
                           .first, with: API::User::Entities::Activity, embed: params[:embed]
      end
    end
  end
end
