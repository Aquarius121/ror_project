class UnitsConverter
  DISTANCE_MAPPING = {'metric' => 'km', 'imperial' => 'mi'}
  VELOCITY_MAPPING = {'metric' => 'km/h', 'imperial' => 'mph'}

  def self.meters_to_mile(meters = 0)
    c = 0.00062137119223733
    (c * meters.to_f).round 1
  end

  def self.meters_to_feet(meters = 0)
    c = 3.28084
    (c * meters.to_f).round 1
  end

  def self.seconds_to_screen(sec = 0)
    sec = sec.to_f
    str = '';
    hours = (sec / 3600).floor
    sec -= hours * 3600
    if hours > 0
      str += hours.to_s + 'h '
    end
    minutes = (sec / 60).floor
    str += minutes.to_s + 'min'
    return str
  end

  def self.seconds_to_time(sec = 0)
    sec = sec.to_f
    str = '';
    hours = (sec / 3600).floor
    sec -= hours * 3600
    str += hours.to_s + ':'
    minutes = (sec / 60).floor
    str += minutes.to_s.rjust(2, '0') + ':'
    sec -= minutes * 60
    str += sec.to_i.to_s.rjust(2, '0')
    return str
  end

  def self.seconds_to_time_short(sec = 0)
    sec = sec.to_f
    str = ''
    hours = (sec / 3600).floor
    sec -= hours * 3600
    str += hours.to_s + ':'
    minutes = (sec / 60).floor
    str += minutes.to_s.rjust(2, '0')
    return str
  end
end