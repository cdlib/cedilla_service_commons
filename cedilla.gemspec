Gem::Specification.new do |s|
  s.name        = 'cedilla'
  s.version     = '0.1.15'
  s.date        = '2014-08-11'
  s.summary     = 'Cedilla Service Commons'
  s.description = 'A gem containing request, citation, author, and resource models as well as a Cedilla JSON <--> Model translator and a base controller and service implementation.'
  s.authors     = ['briley', 'lliu']
  s.email       = 'brian.riley@ucop.edu'
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>=2.0'
  s.files       = Dir['**/**']
  s.homepage    = 'https://github.com/cdlib/cedilla_service_commons'
  s.license     = 'BSD-3-Clause'
  s.has_rdoc    = false
  
  s.files = [
    "Gemfile",
    "Rakefile", 
    "cedilla.gemspec", 
    "LICENSE.md",
    "README.md",
    "lib/cedilla.rb",
    "lib/cedilla/author.rb",
    "lib/cedilla/citation.rb",
    "lib/cedilla/error.rb",
    "lib/cedilla/request.rb",
    "lib/cedilla/resource.rb",
    "lib/cedilla/service.rb",
    "lib/cedilla/translator.rb"]
  
  s.add_dependency 'json', '~> 1.8', '>= 1.8.1'
  s.add_dependency 'rake', '~> 10.1.0', '>= 10.3.2'
  
  s.add_development_dependency 'minitest', '~> 5.4'
  s.add_development_dependency 'webmock', '~> 1.17'
end
