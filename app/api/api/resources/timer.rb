class API::Resources::Timer < Grape::API
  resource :timer do
    desc 'Gets the current timer.'
    get do
      timer = current_user.current_time_sheet.timer
      raise ActiveRecord::RecordNotFound if timer.nil?
      present timer, with: API::Entities::Timer
    end

    desc 'Starts a timer.'
    params do
      requires :time_type_id, type: Integer, time_type_for_timer: true, desc: 'A time type ID.'
      optional :date, type: String, regexp: /\A\d{4}-\d{1,2}-\d{1,2}\z/, desc: 'A date in the format YYYY-MM-DD. Defaults to current date.'
      optional :start, type: String, regexp: /\A\d{1,2}:\d{1,2}\z/,  desc: 'A start time in the format HH:MM. Defaults to current time.'
    end
    post do
      start_date = params[:date] || Date.current
      start_time = params[:start] || Time.current.strftime('%H:%M')
      time_type_id = params[:time_type_id]

      timer = TimeEntry.create!(
        time_sheet_id: current_user.current_time_sheet.id,
        time_type_id: time_type_id,
        start_date: start_date,
        start_time: start_time,
      )

      present timer, with: API::Entities::Timer
    end

    desc 'Updates the current active timer. When an end time is supplied, the timer will stop.'
    params do
      optional :date, type: String, regexp: /\A\d{4}-\d{1,2}-\d{1,2}\z/, desc: 'A date in the format YYYY-MM-DD.'
      optional :start, type: String, regexp: /\A\d{1,2}:\d{1,2}\z/,  desc: 'A start time in the format HH:MM.'
      optional :end, type: String, regexp: /\A((\d{1,2}:\d{1,2})|true)\z/,  desc: 'A end time in the format HH:MM or true. \'true\' will default to current time.'
    end
    put do
      timer = current_user.current_time_sheet.timer
      raise ActiveRecord::RecordNotFound if timer.nil?

      if params[:start].present?
        timer.start_time = params[:start]
      end

      if params[:end].present?
        timer.end_date = timer.start_date
        timer.end_time = params[:end] == 'true' ? Time.current.strftime('%H:%M') : params[:end]
      end

      if params[:date].present?
        timer.start_date = params[:date]
        timer.end_date = params[:date] if timer.end_date.present?
      end

      if timer.ends && timer.starts >= timer.ends
        timer.end_date = timer.start_date + 1
      end

      timer.save!

      present timer, with: API::Entities::Timer
    end

    desc 'Deletes the current active timer.'
    delete do
      timer = current_user.current_time_sheet.timer
      timer.destroy
      present timer, with: API::Entities::Timer
    end

  end
end
