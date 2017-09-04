require_relative 'monomial'
require_relative 'parser'
require_relative '../steps/steps'

module Polymath
  module Nomial
    def self.random_polynomial(n=3, cof_max: 100, skip_chance: 0.25)
      degree = Integer(Random.rand() * n) + 1
      (0..degree).map { |deg|
        if Random.rand <= 1.0 - skip_chance
          "#{Integer(Random.rand * cof_max) - (cof_max / 2)}x^#{deg}"
        end
      }.compact.join("+")
    end

    ##
    ## @brief      Class for a polynomial with integer coefficients and degrees
    ##
    class Polynomial

      attr_reader :exp, :monomials, :interpreted_exp, :steps
      attr_accessor :variable

      ::DefaultVar = "x"

      ##
      ## @brief      Constructs a Polynomial object
      ##
      ## @param      exp   the string polynomial expression
      ##
      ## @return     a new Polynomial object
      ##
      def initialize(exp)
        @steps = Polymath::Steps::Steps.new("polynomial")
        @substep = nil

        @exp = Nomial::Parser.sanitize(exp)
        @monomials = Nomial::Parser.parse(@exp)
        if @monomials.length == 0
          @monomials << Monomial.new(cof: 0, deg: 0, var: ::DefaultVar)
        end
        @variable = Nomial::Parser.guess_variable(self)
        @interpreted_exp = @exp.gsub(/[[:alpha:]]/, @variable)
        cleanup!
      end

      ##
      ## @brief      checks if the supplied expression string was auto-corrected
      ##
      ## @return     boolean
      ##
      def modified_expression?
        interpreted_exp != exp
      end

      ##
      ## @brief      homogenizes each monomial in place
      ##
      ## @return     an array of monomials
      ##
      def homogenize!
        monomials.each { |monomial| monomial.homogenize!(variable) }
      end

      ##
      ## @brief      orders a polynomial expression in descending order by degree
      ##
      ## @return     an  array of monomials in descending order
      ##
      def order
        monomials.sort_by { |monomial| -monomial.deg }
      end

      ##
      ## @brief      collects terms of the same degree
      ##
      ## @return     an array of monomials where all like degrees are merged
      ##
      def collect_terms
        c = (0..deg).map { |n|
          collected = monomials_where_deg(n).reduce(:+)
          collected.cof == 0 ? nil : collected if collected
        }.compact.reverse

        if c.empty?
          [Monomial.new(cof: 0)]
        else
          c
        end
      end

      ##
      ## @brief      homogenizes, collects terms, and orders a polynomial in place
      ##
      ## @return     nil
      ##
      def cleanup!
        substep = @steps.add_group("cleanup")

        homogenize!
        substep.add({title: "homogenize", result: to_s})

        @monomials = order
        substep.add({title: "order",      result: to_s})

        @monomials = collect_terms
        substep.add({title: "collect",    result: to_s})
      end

      ##
      ## @brief      returns all monomials with the specified degree
      ##
      ## @param      n     the specified degree
      ##
      ## @return     an array of monomials with degree == n
      ##
      def monomials_where_deg(n)
        monomials.select { |monomial| monomial.deg == n }
      end

      ##
      ## @brief      returns the degree of the polynomial
      ##
      ## @return     an integer degree
      ##
      def deg
        order.first.deg
      end

      ##
      ## @brief      returns the value of the polynomial's constant
      ##
      ## @param      cof   The cof
      ##
      ## @return     an integer
      ##
      def constant
        (monomials_where_deg(0).first || Monomial.new(cof: 0)).cof
      end

      ##
      ## @brief      returns the value of the polynomial's leading coefficient
      ##
      ## @return     an integer
      ##
      def leading_coefficient
        monomials_where_deg(deg).first.cof
      end

      ##
      ## @brief      returns an array of the polynomial's coefficients
      ##
      ## @return     an array of integers
      ##
      def coefficients
        monomials.map { |monomial| monomial.cof }
      end

      ##
      ## @brief      determines the gcd of the polynomial's coefficients
      ##
      ## @return     an integer
      ##
      def gcd
        coefficients.sort.reduce(:gcd)
      end

      def reduce

      end

      ##
      ## @brief      uses a symbol classification method to classify a polynomial
      ##
      ## @return     a hash
      ##
      def classification
        if (1..3).include?(monomials.length)
          basic = [
            :monomial,
            :binomial,
            :trinomial
          ][monomials.length - 1]

          if basic == :monomial
            if monomials.first.cof == 0
              special = :zero
            elsif monomials.first.deg == 0
              special = :constant
            end
          end
        end

        if (0..10).include?(deg)
          degree = [
            :undefinded,
            :linear,
            :quadratic,
            :qubic,
            :quartic,
            :quintic,
            :hexic,
            :heptic,
            :octic,
            :nonic,
            :decic
          ][deg]
        end

        basic   ||= :polynomial
        special ||= :normal
        degree  ||= :"#{deg}th_degree"

        { :special => special, :deg => degree, :len => basic }
      end

      ##
      ## @brief      displys a string form of the polynomial
      ##
      ## @return     a string
      ##
      def to_s
        monomials.collect { |monomial| monomial.to_s }.reduce { |m, t|
          joiner = t[0] == "-" ? "" : "+"
          m += joiner + t
        }
      end
    end
  end
end
