require 'prime'
require_relative '../steps/steps'

module Polymath

  module Math

    ::ZeroRoot = Rational(0)

    ##
    ## @brief      calculates possible rational zeroes for a given polynomial
    ##
    ## @param      polynomial  The polynomial
    ##
    ## @return     an array of Rational numbers
    ##
    def rational_zeroes(polynomial:)
      cnf = factors_of(polynomial.constant)
      lcf = factors_of(polynomial.leading_coefficient)

      cnf.map { |x|
        lcf.map { |y| [ Rational(x, y), -Rational(x, y) ] }
      }.flatten.uniq
    end

    ##
    ## @brief      Determines if a rational number is a zero for a given
    ##             polynomial
    ##
    ## @param      polynomial  The polynomial
    ## @param      test_value  The test value
    ##
    ## @return     True if a zero, False otherwise.
    ##
    def is_a_zero?(test_value:, polynomial:)
      synthetic_remainder(polynomial: polynomial, divisor: test_value) == 0
    end

    ##
    ## @brief      determines the zeroes of a polynomial
    ##
    ## @param      polynomial  The polynomial
    ##
    ## @return     an array of Rational numbers
    ##
    def factor_rational_zeroes(polynomial:)
      rational_zeroes(polynomial: polynomial).select { |test_value|
        is_a_zero?(test_value: test_value, polynomial: polynomial)
      }
    end

    def factor_zeroes(polynomial:)
      case polynomial.classification[:len]
      when :monomial
        case polynomial.classification[:special]
        when :zero
          [Float::INFINITY]
        else
          [::ZeroRoot]
        end
      else
        factor_rational_zeroes(polynomial: polynomial)
      end
    end

    ##
    ## @brief      calculates the remainder of the synthetic quotient of a
    ##             polynomial and a test value
    ##
    ## @param      polynomial  The polynomial
    ## @param      value       The value
    ##
    ## @return     a Rational number
    ##
    def synthetic_remainder(polynomial:, divisor:)
      polynomial.coefficients.reduce { |carry, next_cof|
        (carry * divisor) + next_cof
      }
    end

    ##
    ## @brief      determine the prime factors of x
    ##
    ## @param      x     the integer to factor
    ##
    ## @return     an array of integers
    ##
    def factors_of(x)
      (x.prime_division.map { |f| f[0] } + [1, x]).uniq.sort
    end

    class MathPlain
      include Math
    end
  end
end
