Time::DATE_FORMATS[:short_ordinal] = lambda { |date|
  day_format = ActiveSupport::Inflector.ordinalize(date.day)
  date.strftime("%B #{day_format}, %Y") # => "April 25th, 2007"
}

Time::DATE_FORMATS[:date_short] = '%b. %d, %Y'
Time::DATE_FORMATS[:date] = '%d %B %Y'
