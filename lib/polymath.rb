require 'optparse'
require 'json'

require_relative 'polymath/nomial/polynomial'
require_relative 'polymath/math/math'

module Polymath
  ::Version = [1, 0, 0]

  ##
  ## @brief      parses command line arguments
  ##
  ## @param      args  The arguments
  ##
  ## @return     a hash of parsed options
  ##
  def self.parse_options(args)

    options = {
      :polynomial => nil,
      :verbose    => true,
      :analyze    => false,
      :factor     => false
    }

    parser = OptionParser.new { |opts|
      opts.banner = "Usage: polymath [options] <polynomial>"

      opts.on("-f", "--factor", "factor the polynomial expression") { |f|
        options[:factor] = f
      }

      opts.on("-a", "--analyze", "analyze the polynomial expression") { |a|
        options[:analyze] = a
      }

      opts.on("-q", "--quiet", "only output what is specified") { |q|
        options[:verbose] = ! q
      }

      opts.on("-r", "--random [N]", "generate a random polynomial") { |n|
        options[:polynomial] =  if n
                                  Nomial::random_polynomial(Integer(n))
                                else
                                  Nomial::random_polynomial
                                end
      }

      opts.on_tail("-h", "--help", "Show this message") {
        puts opts
        exit
      }

      opts.on_tail("--version", "Show version") {
        puts self::Version.join('.')
        exit
      }
    }

    parser.parse!(args)
    options[:polynomial] = args.pop unless options[:polynomial]
    options
  end

  def self.polynomial(exp)
    Polymath::Nomial::Polynomial.new(exp)
  end

  ##
  ## @brief      preforms actions specified by command line arguments
  ##
  ## @param      options  The parsed options
  ##
  ## @return     nil
  ##
  def self.command_line(options)
    raise "No polynomial given" unless options[:polynomial]

    polynomial = Polymath.polynomial(options[:polynomial])
    math       = Polymath::Math.new

    polynomial.cleanup!

    if options[:factor]
      zeroes = math.factor_rational_zeroes(polynomial: polynomial)
    end

    #output
    puts options.map { |opt, value|
      next unless value
      case opt
      when :verbose
        polynomial.to_s
      when :factor
        "zeroes: #{zeroes}" if options[:factor]
      when :analyze
        {
          deg:   polynomial.deg,
          class: polynomial.classification.map { |t, c| c }.compact.join(" ")
        }.map { |a,b| "#{a}: #{b}" }.join("\n")
      end
    }.compact.join("\n")

  end

end
