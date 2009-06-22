module ActiveSesame::Behaviors
  module Ontology
    def self.included(klass)
      class << klass
        attr_accessor :ontology_attribute, :repository
      end

      klass.ontology_attribute = :name
      klass.repository =  ActiveSesame::Repository.new
      klass.class_eval do
        def self.set_ontology_attribute(value,&block)
          block_given? ? attribute_value = yield(value) : attribute_value = value
          self.ontology_attribute = value.to_sym
        end
      end
    end


    def ontology
      @ontology ||= ActiveSesame::Ontology::Term.new(self.send(self.class.ontology_attribute))
    end
  end

  module FuzzyOntology
    #tag class: default to owl:Thing or rdf:Type
    #SPARQL for Radlex:
    ##  SELECT ?name WHERE { {?term <Preferred_Name> ?name} UNION {?otherterm <Synonym_Name> ?name} }
    def self.include_fuzzy_ontology(klass, attribute_name, options={})
      options = {
        :method_name => :terms,
        :sparql => "SELECT ?s WHERE { {?s rdf:Type owl:Thing} UNION {?s rdf:Type rdfs:Class} UNION {?s rdfs:subClass owl:Thing} }"
      }.merge(options)
      repo = ActiveSesame::Repository.new
      repo.find_by_sparql(options[:sparql])
    end

  end
end
