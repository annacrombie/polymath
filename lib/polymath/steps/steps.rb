require_relative 'step'

module Polymath

  module Steps

    def self.stepper(steps)
      steps = Steps.new(steps) if steps.class == String
      ->(step) { steps << step }
    end

    ##
    ## @brief      Class for recording steps used in a computation
    ##
    class Steps

      attr_accessor :steps, :title

      ::Tab = "  "

      ##
      ## @brief      constructor for a steps object
      ##
      ## @param      title  The title of the group of steps
      ##
      ## @return     a new steps object
      ##
      def initialize(title)
        @title = title
        @steps = []
      end

      ##
      ## @brief      add a new step or group of steps to this group of steps
      ##
      ## @param      other the step, step title or step group
      ##
      ## @return     the added step
      ##
      def <<(other)
        #p self
        #p @steps
        #puts "adding #{other.class}"
        case other
        when Steps
          @steps << other
        when Hash
          @steps << Step.new(other)
        when String
          @steps << Steps.new(other)
        else
          raise "Invalid class for Step #{other.class}"
        end
        @steps.last
      end

      ##
      ## @brief      merges the current set of steps with another set of steps
      ##
      ## @param      other  The other set of steps
      ##
      ## @return     a new steps object
      ##
      def merge(other)
        new_group = other
        new_steps = Steps.new(title + " " + other.title)
        new_steps << self
        new_steps << other
        new_steps
      end

      ##
      ## @brief      prints the steps in  a human readable format
      ##
      ## @param      indent  the indentation of the text
      ##
      ## @return     a string
      ##
      def to_s(indent=0)
        tab = (::Tab * indent)
        tab + @title + "\n" + @steps.map { |step|

          if step.class == Steps
            step.to_s(indent+1)
          elsif step.class == Step
            "#{tab}#{step.title}\n#{tab}#{::Tab}#{step.data}\n"
          end
        }.join
      end

      ##
      ## @brief      converts the steps into a hash
      ##
      ## @return     a hash
      ##
      def to_h
        {
          @title => @steps.map { |step|
            if step.class == Steps
              step.to_h
            elsif step.class == Step
              {title: step.title, data: step.data}
            end
          }
        }
      end

    end
  end
end
