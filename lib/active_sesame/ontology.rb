module ActiveSesame::Ontology
  class Term
    attr_reader :relationships, :relationship_map, :type, :term
    extend ActiveSesame::Support

    def method_missing(method, *args, &block)
      if @relationships.has_key?(method.to_s)
        if @relationships[method].class == Term
          @relationships[method]
        else
          @relationships[method] = Term.new(@relationships[method.to_s])
        end
      else
        super(method, *args, &block)
      end
    end

    def initialize(ontoterm, repo = ActiveSesame::Repository.new)
      @@repo = repo
      @term = ontoterm
      set_relationships
    end

    def reset
      set_relationships
    end

    private
    def set_relationships
      if self.class.is_uri?(@term)
        @type = "uri"
        @relationship_map ||= @@repo.find("SELECT ?predicate ?object WHERE { <#{@term}> ?predicate ?object }")
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

end
