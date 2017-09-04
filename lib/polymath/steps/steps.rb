require_relative 'step'

module Polymath

  module Steps

    ##
    ## @brief      Class for recording steps used in a computation
    ##
    class Steps

      attr_accessor :steps, :title

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
      ## @brief      add a new step to this group of steps
      ##
      ## @param      opts  a hash containing a :title and a :result
      ##
      ## @return     an array of steps
      ##
      def add(opts)
        @steps << Step.new(opts)
      end

      ##
      ## @brief      Adds a group of steps
      ##
      ## @param      title  The title of the steps group or another steps object
      ##
      ## @return     a new steps object or string title
      ##
      def add_group(title)
        if title.class == Steps
          @steps << title
          title
        else
          new_group = Steps.new(title)
          @steps << new_group
          new_group
        end
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
        new_steps.add_group(self)
        new_steps.add_group(other)
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
        (" " * indent) + @title + "\n" + @steps.map { |step|
          if step.class == Steps
            step.to_s(indent+1)
          elsif step.class == Step
            "#{"  " * indent}#{step.title} -> #{step.result}\n"
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
              {title: step.title, result: step.result}
            end
          }
        }
      end

    end
  end
end
