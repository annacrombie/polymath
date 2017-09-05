require_relative 'math'

module Polymath
  module Math
    ##
    ## @brief      Class for mathematical operations that can keep track of its
    ##             computations
    ##
    class MathSteps

      attr_accessor :steps

      ##
      ## @brief      constructs a new MathSteps object
      ##
      ## @return     a new MathSteps object
      ##
      def initialize
        @steps = Polymath::Steps::Steps.new("factor")
      end

      ##
      ## @brief      factors a polynomial, keeping track of its steps
      ##
      ## @param      polynomial  The polynomial to factor
      ##
      ## @return     an array of Rational numbers that are roots of the polynomial
      ##
      def factor_rational_zeroes(polynomial)
        Math.factor_special(polynomial) {
          _p = Math::factors_of polynomial.constant
          _q = Math::factors_of polynomial.leading_coefficient

          substeps = steps.add_group("factor_coefficients")
          substeps.add({title: "factor_constant", result: _p})
          substeps.add({title: "factor_coefficient", result: _q})

          substeps = steps.add_group("check_zeroes")

          rz = Math::rational_zeroes(polynomial)
          substeps.add({title: "rational_zeroes", result: rz})

          subsubsteps = substeps.add_group("test_zeroes")
          rz.select { |tv|
            rem  = Math::synthetic_remainder(polynomial, tv)
            is_z = rem == 0

            subsubsteps.add({
              title: "synthetic_division",
              result: {
                test_value: tv,
                remainder:  rem,
                is_a_zero:  is_z
              }
            })
            is_z
          }
        }
      end

      def factor(polynomial)
        factor_rational_zeroes(polynomial)
      end
    end
  end
end
