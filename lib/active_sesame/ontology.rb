module ActiveSesame::Ontology
  class Term
    attr_reader :relationships, :relationship_map, :term_type, :term
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
      @relationships = {}
      @relationship_map = nil
      set_relationships
      true
    end

    def to_triples
      self.relationship_map.collect do |po_hash|
        ActiveSesame::Triple.new({:subject => self.term, :predicate => po_hash["predicate"], :object => po_hash["object"]})
      end
    end

    def add_relationship(triple)
      triple[:subject] = self.term unless triple.class == ActiveSesame::Triple and not (triple.has_key?[:subject] or triple.has_key?["subject"])
      triple = triple.to_triple
      key = self.class.method_from_uri(triple.predicate, :base => @@repo.base_uri)
      if not self.relationships.has_key?(key)
        self.relationships[key] = triple.object
      elsif self.relationships[key].class != Array
        self.relationships[key] = [self.relationships[key], triple.object]
      else
        self.relationships[key] << triple.object
      end
    end

    private
    def set_relationships
      if self.class.is_uri?(@term)
        @term_type = "uri"
        @relationship_map ||= @@repo.find("SELECT ?predicate ?object WHERE { <#{@term}> ?predicate ?object }")
        @relationships = {}
        self.relationship_map.each {|map| self.add_relationship(map) }
      else
        @term_type = "literal"
      end
    end

  end

end
