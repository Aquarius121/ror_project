module GPolyline
  def round_decimal(decimal)
    (decimal * 1e5).round.to_i
  end
end