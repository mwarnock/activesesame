class ActiveSesame::OwlThing
  require 'digest/sha1'
  include ActiveSesame::Support
  #class methods for building the definition of the class
  # - The most basic definition should (when inheriting from OwlThing create the subClassOf triple
  # - The init method is the same for all even owl thing
  #init for creating a new instance of the thing
  # - A method to create a uri for the thing
  # - - This could be <blank> as well

  # OwlThing.new creates a new term that is a rdf:type of owl:Thing
  # when a class is created that inherits from OwlThing the definition for the class term is yet another instantiation of owl thing that can be placed in a class attribute
  # new results in rdf:type relationship, inherited results in rdfs:subClassOf relationship

  # Use class attribute term as the place for keeping
  # Pass in the uri and object through the new() when inherited as called
  # Questions to be answered:
  # -Does self.add_triple/term.add_relationships overwrite relationships or always add to unsaved_triples?


  # TODO:
  # -Be sure that if the term exists that it will populate relationships and what not appropriately
  # -Be sure the "unsaved triples" are not added when the triple already exists
  # -Add find methods:
  # --Find for uri (id equivalent)
  # --find(:all)
  # --find(:all/:first, :conditions => "?self rdf:type #{self.class.term.term} . user input" (made with sparql query object?)

  class << self
    attr_accessor :repository, :term, :uri
  end

  attr_accessor :uri, :term

  def self.inherited(klass)
    klass.term.add_triple({:subject => "base:#{klass}", :predicate => "rdfs:subClassOf", :object => "owl:Thing"})
  end

  def self.repository
    @repository ||= self.repository = ActiveSesame::Repository.new #Setting default repository
  end

  def self.set_repository(repo)
    self.repository = repo
    self.reset_term
  end

  def self.uri
    @uri ||= "base:" + self.to_s.split("::").last
  end

  def self.set_uri(uri)
    self.uri = uri
    self.reset_term
  end

  def self.term
    @term ||= ActiveSesame::Ontology::Term.new(uri, self.repository)
  end

  def self.reset_term
    @term = ActiveSesame::Ontology::Term.new(uri, self.repository)
    @term.add_triple({:subject => "base:#{self}", :predicate => "rdfs:subClassOf", :object => "owl:Thing"})
  end


  def self.method_missing(method, *args, &block)
    self.term.send(method, *args, &block)
  end

  def method_missing(method, *args, &block)
    self.term.send(method, *args, &block)
  end

  def initialize(options={})
    @uri = options[:uri] if options[:uri]
    @uri ||= self.generate_uri
    @term = ActiveSesame::Ontology::Term.new(@uri, self.class.repository)
    self.add_triple({:subject => @uri, :predicate => "rdf:type", :object => self.class.uri}) if @term.relationships.size == 0
  end

  def repository
    self.class.repository
  end

  def generate_uri
    self.repository.base_uri + "#" + Digest::SHA1.hexdigest(Time.now.to_s + self.object_id.to_s)
  end

  @uri = "owl:Thing" #Set the default URI to the correct owl term

end
