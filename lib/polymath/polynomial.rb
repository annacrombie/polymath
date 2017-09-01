require_relative 'token'
require_relative 'steps/steps'

module Polymath

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

    attr_reader :exp, :tokens, :interpreted_exp, :steps
    attr_accessor :variable

    ##
    ## @brief      Constructs a Polynomial object
    ##
    ## @param      exp   the string polynomial expression
    ##
    ## @return     a new Polynomial object
    ##
    def initialize(exp)
      @steps = Polymath::Steps.new("polynomial")
      @substep = nil

      @exp = exp.split.join
      @tokens = tokenize(@exp)
      @tokens << Token.new(cof: 0, deg: 0, var: "x") if @tokens.length == 0
      @variable = guess_variable
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
    ## @brief      gets a list of all variables in the expression
    ##
    ## @return     an array of variables
    ##
    def variables
      tokens.select { |token| token.var != "?" }.map { |token| token.var }
    end

    ##
    ## @brief      guesses which variable the user meant by frequency
    ##
    ## @return     string of length 1
    ##
    def guess_variable
      if variables.length == 0
        "x"
      else
        variables.uniq.map { |char|
          {
            count: variables.count(char),
            char:  char
          }
        }.sort_by { |c| -c[:count] }.first[:char]
      end
    end

    ##
    ## @brief      tokenizes a string polynomial expression
    ##
    ## @param      exp   the string polynomial expression
    ##
    ## @return     an array of tokens
    ##
    def tokenize(exp)
      exp.split(/\+|(?=-)/).map { |token|
        token.split(/(?=[[:alpha:]])/).map { |subtoken|
          if /[[:alpha:]]/.match?(subtoken)
            Token.new(
              var: subtoken.scan(/[[:alpha:]]/).join,
              deg: /\^/.match?(subtoken) ? Integer(subtoken.scan(/\^(.*)/).join) : 1,
              cof: /\-/.match?(subtoken) ? -1 : nil
            )
          elsif /\d/.match?(subtoken)
            Token.new(cof: Integer(subtoken))
          elsif subtoken == "-"
            Token.new(cof: -1)
          end
        }.compact.reduce(:merge!)
      }
    end


    ##
    ## @brief      homogenizes each token in place
    ##
    ## @return     an array of tokens
    ##
    def homogenize!
      tokens.each { |token| token.homogenize(variable) }
    end

    ##
    ## @brief      orders a polynomial expression in descending order by degree
    ##
    ## @return     an  array of tokens in descending order
    ##
    def order
      tokens.sort_by { |token| -token.deg }
    end

    ##
    ## @brief      collects terms of the same degree
    ##
    ## @return     an array of tokens where all like degrees are merged
    ##
    def collect_terms
      (0..deg).map { |n| tokens_where_deg(n).reduce(:+) }.compact
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

      @tokens = collect_terms
      substep.add({title: "collect",    result: to_s})

      @tokens = order
      substep.add({title: "order",      result: to_s})
    end

    ##
    ## @brief      returns all tokens with the specified degree
    ##
    ## @param      n     the specified degree
    ##
    ## @return     an array of tokens with degree == n
    ##
    def tokens_where_deg(n)
      tokens.select { |token| token.deg == n }
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
      (tokens_where_deg(0).first || Token.new(cof: 0)).cof
    end

    ##
    ## @brief      returns the value of the polynomial's leading coefficient
    ##
    ## @return     an integer
    ##
    def leading_coefficient
      tokens_where_deg(deg).first.cof
    end

    ##
    ## @brief      returns an array of the polynomial's coefficients
    ##
    ## @return     an array of integers
    ##
    def coefficients
      tokens.map { |token| token.cof }
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
      if (1..3).include?(tokens.length)
        basic_classification = [:monomial, :binomial, :trinomial][tokens.length - 1]
        if basic_classification == :monomial
          if tokens.first.cof == 0
            special_classification = :zero
          elsif tokens.first.deg == 0
            special_classification = :constant
          end
        end
      else
        basic_classification = :polynomial
      end

      if (0..10).include?(deg)
        degrees = [:undefinded, :linear, :quadratic, :qubic, :quartic, :quintic, :hexic, :heptic, :octic, :nonic, :decic]
        degree_classification = degrees[deg]
      end

      classification ||= :normal
      degree_classification ||= :"#{deg}th_degree"

      {
        :deg => degree_classification,
        :spc => special_classification,
        :len => basic_classification,
      }
    end

    ##
    ## @brief      converts the classification into a string
    ##
    ## @return     a classification string
    ##
    def string_classification
      classification.map { |t, c| c }.compact.join(" ")
    end


    ##
    ## @brief      gives information about the polynomial
    ##
    ## @return     a string
    ##
    def analyze
      {
        :degree => deg,
        :class  => string_classification
      }.map { |a, b| "#{a}: #{b}" }.join("\n")
    end

    ##
    ## @brief      displys a string form of the polynomial
    ##
    ## @return     a string
    ##
    def to_s
      tokens.collect { |token| token.to_s }.reduce { |m, t|
        joiner = t[0] == "-" ? "" : "+"
        m += joiner + t
      }
    end
  end

end
