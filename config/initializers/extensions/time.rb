class Time
  def round(seconds = UberZeit::Config[:rounding])
    Time.at((self.to_f / seconds).round * seconds).utc
  end

  def floor(seconds = UberZeit::Config[:rounding])
    Time.at((self.to_f / seconds).floor * seconds).utc
  end
end