require_relative 'monomial'
module Polymath
  module Nomial
    class Parser

      def self.sanitize(exp)
        exp.gsub(/\s/, '')
      end

      ##
      ## @brief      parses a string polynomial expression
      ##
      ## @param      exp   the string polynomial expression
      ##
      ## @return     an array of monomials
      ##
      def self.parse(exp)
        exp.split(/\+|(?=-)/).map { |monomial|
          monomial.split(/(?=[[:alpha:]])/).map { |token|
            if /[[:alpha:]]/.match?(token)
              Monomial.new(
                var: token.scan(/[[:alpha:]]/).join,
                deg: /\^/.match?(token) ? Integer(token.scan(/\^(.*)/).join) : 1,
                cof: /\-/.match?(token) ? -1 : nil
              )
            elsif /\d/.match?(token)
              Monomial.new(cof: Integer(token))
            elsif token == "-"
              Monomial.new(cof: -1)
            end
          }.compact.reduce(:merge!)
        }
      end

      ##
      ## @brief      guesses which variable the user meant by frequency
      ##
      ## @return     string of length 1
      ##
      def self.guess_variable(polynomial)
        variables = polynomial.monomials.select { |monomial|
          monomial.var != "?"
        }.map { |monomial| monomial.var }

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

    end
  end
end
