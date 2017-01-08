# THIS FIXES [FLOAT].to_s 16,
# because somehow there's no such method with args!

# This works in production, but gives me stack overflow in development when classes are reloaded
# The actual code that leads to an error in sass lib is this gem: vincenty, file vincenty-1.0.6/lib/core_extensions.rb
# I've opened an issue with this lib, but temp fix is just to comment ot Float class extension in the gem for now, and comment this file.
#
# @idoroshin: good to have this one \o/, cuz sass is definetely has no such method
#             but to keep it away from stack overflow error i've commented out rails.to_prepare
#             because somehow it reloads given block on every autoload class reload,
#             which causes an error (class already evaled)


# Rails.configuration.to_prepare do
  Float.class_eval do
    alias_method :def_to_s, :to_s

    def to_s *args
      if args.present?
        to_i.to_s *args
      else
        send :def_to_s
      end
    end
  end
# end
