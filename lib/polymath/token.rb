module Polymath

  class Token

    attr_accessor :cof, :deg, :var

    def initialize(cof:1, deg:0, var:"?")
      @cof, @deg, @var = cof, deg, var
    end

    def homogenize(new_var)
      @cof = 1       unless cof
      @deg = 0       unless deg
      @var = new_var
    end

    def merge!(other)
      @cof *= other.cof if other.cof
      @deg += other.deg if other.deg
      @var = other.var  if other.var != "?"
      self
    end

    def +(other)
      raise Error unless deg == other.deg
      raise Error unless var == other.var
      Token.new(cof:@cof + other.cof, deg:deg, var:var)
    end

    def to_s
      if deg > 0
        "#{cof == 1 ? "" : cof}" + "#{var}" + (deg > 1 ? "^#{deg}" : "")
      else
        "#{cof}"
      end
    end

  end

end
