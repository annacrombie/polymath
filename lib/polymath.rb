require 'optparse'
require 'json'

require_relative 'polymath/nomial/polynomial'
require_relative 'polymath/math/math_steps'

module Polymath
  self::Version = [1, 0, 0]

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
      :factor => false,
      :record => :none,
      :analyze => false,
      :quiet => false
    }

    parser = OptionParser.new { |opts|
      opts.banner = "Usage: polymath [options] <polynomial>"

      opts.on("-f", "--factor", "factor the polynomial expression") { |f|
        options[:factor] = f
      }

      opts.on("-a", "--analyze", "analyze the polynomial expression") { |a|
        options[:analyze] = a
      }

      opts.on("--json", "output json steps") {
        options[:record] = :json
      }

      opts.on("--steps", "output human readable steps") {
        options[:record] = :human
      }

      opts.on("-q", "--quiet", "only output what is specified") { |q|
        options[:quiet] = q
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

  ##
  ## @brief      preforms actions specified by command line arguments
  ##
  ## @param      options  The parsed options
  ##
  ## @return     nil
  ##
  def self.command_line(options)
    raise "No polynomial given" unless options[:polynomial]

    polynomial = Polymath::Nomial::Polynomial.new(options[:polynomial])

    case options[:record]
    when :none
      zeroes = Polymath::Math.factor_rational_zeroes(polynomial) if options[:factor]
    else
      steps = polynomial.steps
      if options[:factor]
        math_steps = Polymath::Math::MathSteps.new
        zeroes = math_steps.factor_rational_zeroes(polynomial)
        steps = polynomial.steps.merge(math_steps.steps)
      end
    end

    puts "#{polynomial}" unless options[:quiet]
    if options[:analyze]
      puts "deg: #{polynomial.deg}"
      puts "class: #{polynomial.classification.map { |t, c| c }.compact.join(" ")}"
    end
    case options[:record]
    when :human
      puts steps
    when :json
      puts JSON.pretty_generate(steps.to_h)
    end
    puts "zeroes: #{zeroes}" if options[:factor]
  end

end
