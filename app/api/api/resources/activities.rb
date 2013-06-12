class API < Grape::API
  module Resources
    class Activities < Grape::API

      resource :activities do
        desc 'Lists all activities'
        get do
          present Activity.all, with: Entities::Activity
        end

        desc 'Creates an activity.'
        params do
          requires :activity_type_id, type: Integer
          requires :date, type: Date
          requires :duration, type: Integer, desc: 'Activity duration in seconds'
          optional :description, type: String
          optional :customer_id, type: Integer
          optional :project_id, type: Integer
          optional :redmine_ticket_id, type: Integer
          optional :otrs_ticket_id, type: Integer
        end
        post do
          activity = Activity.create(
            activity_type_id: params[:activity_type_id],
            date: params[:date],
            duration: params[:duration],
            description: params[:description],
            customer_id: params[:customer_id],
            project_id: params[:project_id],
            redmine_ticket_id: params[:redmine_ticket_id],
            otrs_ticket_id: params[:otrs_ticket_id],
            user_id: current_user.id
          )
          present activity, with: Entities::Activity
        end

        namespace :redmine_ticket do
          desc 'Retrieves all activities associated with the supplied redmine ticket id'
          params do
            requires :redmine_ticket_id
          end
          get ':redmine_ticket_id' do
            present Activity.redmine_ticket(params[:redmine_ticket_id]), with: Entities::Activity
          end
        end
      end

    end
  end
end
