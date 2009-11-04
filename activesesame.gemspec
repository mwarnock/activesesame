Gem::Specification.new do |s|
  s.name = "activesesame"
  s.summary = "A Ruby Gem for interacting with RDF/OWL stored in the AllegroGraph Triple Store via Seasame 2 HTTP protocol"
  s.description = "A Ruby Gem for interacting with RDF/OWL stored in the AllegroGraph Triple Store via Seasame 2 HTTP protocol.  Go to http://wiki.github.com/mwarnock/activesesame"
  s.email = "circuitshaman@gmail.com"
  s.version = "0.1.1"

  s.authors = ["Max Warnock"]
  s.date = "2009-11-04"
  s.homepage = "http://github.com/mwarnock/activesesame"

  s.files = Dir["README.txt", "CHANGELOG.txt", "Rakefile","init.rb","install.rb","#{File.dirname(__FILE__)}/lib/*.rb","#{File.dirname(__FILE__)}/lib/active_sesame/*.rb", "#{File.dirname(__FILE__)}/spec/*", "#{File.dirname(__FILE__)}/tasks/*.rake"]
  s.require_paths = ["lib"]
  s.add_dependency('libxml-ruby', '>= 1.1.3')
  s.add_dependency('rest-open-uri', '>= 1.0.0')
end
