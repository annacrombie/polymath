require 'test/unit'
require_relative '../lib/polymath/polynomial'

class TestPolynomial < Test::Unit::TestCase
  include Polymath

  # the parser will guess the polynomial's variable
  #
  # @return     { description_of_the_return_value }
  #
  def test_parsing
    polynomial = Polynomial.new("15x^3+15x^332-4xx^2-3y-2")
    assert_equal polynomial.to_s, "15x^332+11x^3-3x^1-2"
    assert_equal polynomial.deg, 332
    assert_equal polynomial.variable, "x"
  end

end
