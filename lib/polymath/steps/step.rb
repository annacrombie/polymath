module Polymath

  module Steps
    ##
    ## @brief      Class for a single step.
    ##
    class Step

      attr_accessor :title, :data

      ##
      ## @brief      Constructs a new step
      ##
      ## @param      title   The title of the step
      ## @param      result  The result of the step
      ##
      ## @return     a new step object
      ##
      def initialize(title:, data:)
        @title = title
        @data  = data
      end

    end
  end
end
