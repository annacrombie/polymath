module Polymath
  class TooManyVariablesError < StandardError
      def initialize(msg="There are too many variables in this polynomial")
        super
      end
    end
  end
end
