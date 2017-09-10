# Polymath
[![Gem Version](https://d25lcipzij17d.cloudfront.net/badge.svg?id=rb&type=6&v=1.0.0&x2=0)](https://rubygems.org/gems/polymath)
A library for polynomials with integer coefficients

## install:
    gem install polymath

## usage:

### lib:
```ruby
require 'polymath'
polynomial = Polymath.polynomial("x^2 - 3x + 2")
polynomial.cleanup!
polynomial.to_s #=> "x^2-3x+2"
```

### command line:
```
$ polymath -af "x^2 - 3x + 2"
x^2-3x+2
deg: 2
class: normal quadratic trinomial
zeroes: [(1/1), (2/1)]
```

## docs:
http://www.rubydoc.info/gems/polymath
