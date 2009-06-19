module ActiveSesame::Ontology
  class Term
    attr_reader :relationships, :relationship_map, :type, :term
    extend ActiveSesame::Support

    def method_missing(method, *args, &block)
      if @relationships.has_key?(method.to_s)
        Term.new(@relationships[method.to_s])
      else
        super(method, *args, &block)
      end
    end

    def initialize(ontoterm)
      @@repo ||= ActiveSesame::Repository.new
      @term = ontoterm
      if self.class.is_uri?(@term)
        @type = "uri"
        @relationship_map = @@repo.find("SELECT ?predicate ?object WHERE { <#{@term}> ?predicate ?object }")
        @relationships = relationship_map.inject(Hash.new) do |hash,map|
          map["predicate"].include?("#") ? key = map["predicate"].split("#")[1] : key = map["predicate"]
          if hash[key].class == NilClass
            hash[key] = map["object"]
          elsif hash[key].class != Array
            hash[key] = [hash[key], map["object"]]
          else
            hash[key] << map["object"]
          end
          hash
        end
      else
        @type = "literal"
      end
    end
  end

  #Cool idea, not sure what I had in mind anymore
  #module Mutator
  #  def self.mutate_owl_class(klass)
  #  end
  #end
end
