require 'date'
require_relative 'lib/polymath'

Gem::Specification.new do |s|
  s.name        = 'polymath'
  s.version     = Version.join(".")
  s.date        = Date.today.strftime('%Y-%m-%d')
  s.summary     = "polynomial library"
  s.description = "polynomial library"
  s.authors     = ["annacrombie"]
  s.email       = 'stone.tickle@gmail.com'

  s.files       = Dir.glob("./lib/**/*.rb") +
                  Dir.glob("./test/**/*.rb") +
                  ["./README.md"]

  s.homepage    = 'https://github.com/uab-cs/polymath/'
  s.license     = 'MIT'
end
