require 'prime'
require_relative '../steps/steps'

module Polymath

  module Math

    ##
    ## @brief      calculates possible rational zeroes for a given polynomial
    ##
    ## @param      polynomial  The polynomial
    ##
    ## @return     an array of Rational numbers
    ##
    def self.rational_zeroes(polynomial)
      _p = factors_of polynomial.constant
      _q = factors_of polynomial.leading_coefficient

      _p.map { |x|
        _q.map { |y|
          [ Rational(x, y), -Rational(x, y) ]
        }
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
    def self.is_a_zero?(polynomial, test_value)
      synthetic_remainder(polynomial, test_value) == 0
    end

    ##
    ## @brief      determines the zeroes of a polynomial
    ##
    ## @param      polynomial  The polynomial
    ##
    ## @return     an array of Rational numbers
    ##
    def self.factor_rational_zeroes(polynomial)
      return Float::INFINITY if polynomial.classification[:special] == :zero
      rational_zeroes(polynomial).select { |tv|
        is_a_zero?(polynomial, tv)
      }
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
    def self.synthetic_remainder(polynomial, value)
      polynomial.coefficients.reduce { |carry, next_cof|
        (carry * value) + next_cof
      }
    end

    ##
    ## @brief      determine the prime factors of x
    ##
    ## @param      x     the integer to factor
    ##
    ## @return     an array of integers
    ##
    def self.factors_of(x)
      (x.prime_division.map { |f| f[0] } + [1, x]).uniq.sort
    end

  end

end
