module ActiveSesame::Ontology
  class Term

    class << self
      attr_accessor :repository
    end

    attr_reader :relationships, :relationship_map, :term_type, :term, :unsaved_triples
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
      self.class.repository = repo
      @term = ontoterm
      @unsaved_triples = []
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
      key = self.class.method_from_uri(triple.predicate, "base" => self.class.repository.base_uri) #This is using rdf constants
      if not self.relationships.has_key?(key)
        self.relationships[key] = triple.object
      elsif self.relationships[key].class != Array
        self.relationships[key] = [self.relationships[key], triple.object]
      else
        self.relationships[key] << triple.object
      end
    end

    def add_triple(triple)
      expanded_triple = self.class.expand_triple(triple, self.class.repository.prefixes.merge({"base" => self.class.repository.base_uri}))
      self.unsaved_triples << expanded_triple
      self.add_relationship(expanded_triple)
    end


    def save
      success = self.class.repository.group_save(self.transactions)
      if success
        @unsaved_triples = []
        success
      else
        success
      end
    end

    def transactions
      ActiveSesame::TransactionBuilder.build_triples(self.unsaved_triples)
    end

    private
    def set_relationships
      @term = self.class.expand_term(@term, self.class.repository.prefixes.merge({"base" => self.class.repository.base_uri}))
      if self.class.is_uri?(@term)
        @term_type = "uri"
        @relationship_map ||= self.class.repository.find("SELECT ?predicate ?object WHERE { <#{@term}> ?predicate ?object }")
        @relationships = {}
        self.relationship_map.each {|map| self.add_relationship(map) }
      else
        @term_type = "literal"
      end
    end


  end

end
