class AbsencesController < ApplicationController

  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :absence, through: :time_sheet

  def index
    year = params[:year] || Time.current.year
    @year = year.to_i

    @time_types = TimeType.absences
    @absences = {}
    time_chunks_finder = FindTimeChunks.new(@time_sheet.absences)
    time_chunks_finder.in_year(@year).each do |chunk|
      chunk.range.to_date_range.each do |day|
        @absences[day.to_s] ||= []
        @absences[day.to_s] << chunk
      end
    end

    @absence = @time_sheet.absences.new

  end

  def new
    @absence.build_recurring_schedule
  end

  def create
    @absence.save
  end

end
