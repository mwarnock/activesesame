module ActiveSesame
  #defined?("ACTIVE_SESAME_ROOT") ? path = ACTIVE_SEASAME_ROOT : 
  path = File.dirname(__FILE__)
  %w(monkey_patches rdf_constants result_parser support repository transaction_builder ontology base behaviors owl_thing).each do |f|
    require File.join(path, f)
  end
end
