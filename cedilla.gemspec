Gem::Specification.new do |s|
  s.name        = 'cedilla'
  s.version     = '0.1.13'
  s.date        = '2014-08-01'
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
  
  gem.files = [
    "Gemfile",
    "Rakefile", 
    "cedilla.gemspec", 
    "LICENSE.txt",
    "README.md",
    "lib/cedilla.rb",
    "lib/cedilla/author.rb",
    "lib/cedilla/cittion.rb",
    "lib/cedilla/error.rb",
    "lib/cedilla/request.rb",
    "lib/cedilla/resource.rb",
    "lib/cedilla/service.rb",
    "lib/cedilla/translator.rb"]
  
  gem.add_dependency 'json', '~> 1.8', '>= 1.8.1'
  gem.add_dependency 'rake', '~> 10.3', '>= 10.3.2'
  
  gem.add_development_dependency 'minitest', '~> 5.40'
  gem.add_development_dependency 'webmock', '~> 1.17'
end
