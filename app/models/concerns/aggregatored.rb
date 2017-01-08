module Aggregatored
  def aggregator_class
    klass = [self.class.name, :Aggregator].join
    p klass
    klass.constantize
  rescue LoadError
    nil
  end

  def aggregator val = nil, user = nil
    (@aggregator ||= aggregator_class.new self, user).tap do |a|
      a.reactify! val unless val.nil?
    end
  rescue
    nil
  end
end
