module ActiveSesame
  #defined?("ACTIVE_SESAME_ROOT") ? path = ACTIVE_SEASAME_ROOT : 
  path = "./"
  %w(monkey_patches rdf_constants result_parser support repository transaction_builder ontology base behaviors owl_thing spec_helpers).each do |f|
    require path + f
  end
end
