class ActiveSesame::OwlThing
  require 'digest/sha1'
  #class methods for building the definition of the class
  # - The most basic definition should (when inheriting from OwlThing create the subClassOf triple
  # - The init method is the same for all even owl thing
  #init for creating a new instance of the thing
  # - A method to create a uri for the thing
  # - - This could be <blank> as well

  # OwlThing.new creates a new term that is a subclass of owl:Thing
  # when a class is created that inherits from OwlThing the definition for the class term is yet another instantiation of owl thing that can be placed in a class attribute
  # new results in IsA relationship, inherited results in subClassOf relationship

  class << self
    attr_accessor :repository
  end

  attr_accessor :uri, :term, :unsaved_triples

  def self.set_repository(repo)
    self.repository = repo
  end

  def self.repository
    @@repository ||= ActiveSesame::Repository.new
  end

  def method_missing(method, *args, &block)
    if self.term.respond_to?(method)
      self.term.send(method, *args, &block)
    else
      super(method, *args, &block)
    end
  end

  def initialize(uri=nil)
    @uri = uri if uri
    @uri ||= self.generate_uri
    @term = ActiveSesame::Ontology::Term.new(@uri)
    self.add_triple({:subject => @uri, :predicate => "owl:isA", :object => "owl:Thing"}) if @term.relationships.size == 0
  end

  private
  def generate_uri
    self.class.repository.base_uri + Digest::SHA1.hexdigest(Time.now.to_s + self.object_id.to_s)
  end

  def add_triple(triple)
    self.unsaved_triples << triple
    self.term.relationships[triple[:predicate]] = triple[:object]
  end
end
