
module ActiveSesame
  ObjectSpace.const_defined?("ACTIVE_SESAME_ROOT") ? path = ACTIVE_SEASAME_ROOT : path = "./"
  %w(monkey_patches rdf_constants result_parser support repository ontology transaction_builder base).each do |f|
    require path + f
  end
end
