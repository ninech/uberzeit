module DateHelper
  def load_day
    unless params[:date].nil?
      @day = Time.zone.parse(params[:date]).to_date
    end
    @day ||= Time.zone.today
  end
end
