module ActiveSesame
  #
  # The represenation and means of exploring RDF Classes
  #
  class RDFClass

    attr_reader :name, :properties, :subclasses, :superclass

    def self.find(klass, options={})
      @@connection ||= Repository.new
      class_types.inject([]) {|memo, type| ResultParser.singular_values(@@connection.find_by_sparql("SELECT ?klass WHERE { ?klass rdf:type #{type} }")) }
    end

    def self.class_types
      ["rdf:Class", "owl:Class", "owl:Thing"]
    end

    def initialize(name)
      self.name = name
      self.properties = find_properties
      self.sublcasses = find_subclasses
      self.superclass = find_superclass
    end

    def find_properties
      ResultParser.singular_values(@@connection.find_by_sparql("SELECT ?property WHERE { #{self.name} rdf:property ?property }"))
    end

    def find_subclasses
      ResultParser.singular_values(@@connection.find_by_sparql("SELECT ?subClasses WHERE { #{self.name} rdf:subClassOf ?subClasses }"))
    end

    def find_superclass
      ResultParser.singular_values(@@connection.find_by_sparql("SELECT ?super WHERE { ?super rdfs:subClassOf #{self.name} }"))
    end

    def add_triple(*args)
      if args.size == 3
        Repository.save_triple(args[0], args[1], args[3])
      elsif args.size == 1 and (args[0].class == Triple or args[0].class == Hash)
        Repository.save_triple(args[0][:subject], args[0][:predicate], args[0][:object])
      end
    end
  end
end

