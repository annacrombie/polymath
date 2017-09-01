module Polymath
  ##
  ## @brief      Class for a single step.
  ##
  class Step

    attr_accessor :title, :result

    ##
    ## @brief      Constructs a new step
    ##
    ## @param      title   The title of the step
    ## @param      result  The result of the step
    ##
    ## @return     a new step object
    ##
    def initialize(title:, result:)
      @title  = title
      @result = result
    end

  end
end
