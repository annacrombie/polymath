require_relative 'math'

module Polymath
  module Math
    def self.step_wrap(*meths)
      meths.each { |meth|
        m = instance_method(meth)
        define_method(meth) { |*args, &block|

          outer_stepper = @stepper
          substep       = @stepper.call(meth.to_s)
          @stepper      = Steps.stepper(substep)

          result        = m.bind(self).(*args, &block)

          args.map! { |arg|
            case arg
            when Hash
              arg.map { |t, v| [t, v.to_s]}.to_h
            else
              arg
            end
          }

          @stepper = outer_stepper

          substep << {
            title: meth.to_s,
            data: {args: args, result: result}
          }

          result
        }
      }
    end

    step_wrap(*instance_methods)

    ##
    ## @brief      Class for mathematical operations that can keep track of its
    ##             computations
    ##
    class MathSteps
      attr_accessor :steps
      include Math
      def initialize
        @steps   = Steps::Steps.new("math")
        @stepper = Steps.stepper(steps)
      end
    end
  end
end
