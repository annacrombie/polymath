require_relative 'math'

module Polymath
  module Math
    @__steps = Steps::Steps.new("math")
    def self.step_wrap(*meths)
      meths.each { |meth|
        m = instance_method(meth)
        define_method(meth) { |*args, &block|

          #substep = yield(meth.to_s)

          result  = m.bind(self).(*args, &block) #Steps.stepper(substep))

          args.map! { |arg|
            case arg
            when Hash
              arg.map { |t, v| [t, v.to_s]}.to_h
            else
              arg
            end
          }

          yield({
            title: meth.to_s,
            data: {args: args, result: result}
          })

          result
        }
      }
    end

    step_wrap(*instance_methods, &Steps.stepper(@__steps))

    ##
    ## @brief      Class for mathematical operations that can keep track of its
    ##             computations
    ##
    class MathSteps
      include Math
      def steps
        Math.instance_variable_get(:@__steps)
      end
    end
  end
end
