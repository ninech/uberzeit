class Time
  def round(seconds = nil)
    seconds ||= UberZeit.config.rounding_minutes.minutes
    Time.at((self.to_f / seconds).round * seconds).utc
  end

  def floor(seconds = nil)
    seconds ||= UberZeit.config.rounding_minutes.minutes
    Time.at((self.to_f / seconds).floor * seconds).utc
  end
end
