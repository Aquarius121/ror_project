class BaseAggregator
  def reactify! val = true
    @reactify = val
  end

  def initialize instance, user = nil
    @instance = instance
    @user     = user # USED FOR AUTHORIZATION
  end

  class << self
    def expand_to
      9
    end

    def wrap options={}
      methods = instance_methods(false)

      if options[:except].present?
        except   = options[:except]
        methods -= except
      elsif options[:only].present?
        only     = options[:only]
        methods &= only
      end

      methods.each do |m|
        old_method = ([:raw, m].join '_').to_sym
        alias_method old_method, m

        define_method m do |*args|
          if @reactify
            send(old_method, *args).take(9).map{|i| i.reactify @user }
          else
            send old_method, *args
          end
        end
      end
    end
  end
end
