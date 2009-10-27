require 'active_sesame'
require 'spec_helpers'

describe ActiveSesame do

  it "should load all it's libraries" do
    ActiveSesame.const_defined?("Base").should be_true
    ActiveSesame.const_defined?("Repository").should be_true
    ActiveSesame.const_defined?("ResultParser").should be_true
    ActiveSesame.const_defined?("TransactionBuilder").should be_true
    ActiveSesame.const_defined?("RDFConstants").should be_true
    ActiveSesame.const_defined?("MonkeyPatches").should be_true
    ActiveSesame.const_defined?("Support").should be_true
    ActiveSesame.const_defined?("Ontology").should be_true
    ActiveSesame.const_defined?("Behaviors").should be_true
  end

  describe ActiveSesame::Behaviors do
    describe ActiveSesame::Behaviors::Ontology do
      before(:all) do
        @repo = SpecHelpers.repository
        SpecHelpers.populate_triple_store
      end

      after(:all) do
        SpecHelpers.clear_triple_store
      end

      before(:each) do
        class TermTest
          attr_accessor :name
          ActiveSesame::Behaviors::Ontology.mimic(self, :repository => SpecHelpers.repository)
        end
        @term = TermTest.new
        @term.name = "http://www.fakeontology.org/ontology.owl#Enders_Game"
      end

      it "should bootstrap the class" do
        @term.respond_to?(:ontology).should be_true
        @term.ontology.term.should be_equal(@term.send(@term.class.ontology_attribute))
      end

      it "should have relationships" do
        @term.ontology.relationships.keys.size.should_not be_equal(0)
      end

      it "'s relationships should include an ontology term" do
        @term.ontology.base_author.class.should be_equal(ActiveSesame::Ontology::Term)
      end

    end

    it "should make a sparql query" do
      #ActiveSesame::Behaviors::FuzzyOntology.include_fuzzy_ontology(self, :bogus).should_not be_equal(nil)
    end
  end

  describe ActiveSesame::ResultParser do
  end


  describe ActiveSesame::Base do
  end
end

describe ActiveSesame::Repository do
  before do
    @repo = ActiveSesame::Repository.new(ActiveSesame::SesameProtocol, {
                                           :repository_uri => "http://localhost:8111/sesame/repositories",
                                           :triple_store_id => "test",
                                           :location => "http://localhost:8111/sesame/repositories/test",
                                           :query_language => "SPARQL",
                                           :base_uri => "http://www.fakeontology.org/ontology.owl#"
                                         })
  end

  it "should add triples to the store" do
    @repo.group_save(ActiveSesame::TransactionBuilder.build_triples(SpecHelpers.triples_to_add, "add"))
    @repo.size.to_i.should_not be_equal(0)
  end

  it "should remove triples from the store" do
    @repo.group_save(ActiveSesame::TransactionBuilder.build_triples(SpecHelpers.triples_to_add, "remove"))
    @repo.size.to_i.should be_equal(0)
  end

  it "should be able to connect to the test triple store" do
    results = open("http://localhost:8111/sesame/repositories", :method => :get).read
    results.include?("http://localhost:8111/sesame/repositories/test").should be_true
  end
end

describe ActiveSesame::OwlThing do
  before do
    class Book < ActiveSesame::OwlThing
    end
  end

  it "should create a new thing with a generated uri" do
    thing = ActiveSesame::OwlThing.new()
    thing.term.term.should =~ /#{ActiveSesame::OwlThing.repository.base_uri}\#.*/
  end

  it "should build a class with the correct relationships" do
    class Author < ActiveSesame::OwlThing
    end
    Author.term.class.should be_equal(ActiveSesame::Ontology::Term)
    Author.term.unsaved_triples.first[:predicate].should == "http://www.w3.org/2000/01/rdf-schema#subClassOf"
  end

  it "should pass unknown methods to term" do
    Book.respond_to?(:unsaved_triples).should be_equal(false)
    Book.unsaved_triples.class.should be_equal(Array)
  end

  it "should have the correct uri and repository when setters are called" do
    class Author < ActiveSesame::OwlThing
      set_repository SpecHelpers.repository
    end
    Author.repository.base_uri.should == SpecHelpers.repository.base_uri
    Author.unsaved_triples.first[:subject].should == "http://www.fakeontology.org/ontology.owl#Author"
    Author.set_uri("http://bogus.org/ontology.owl#JimBob")
    Author.repository.base_uri.should == SpecHelpers.repository.base_uri
    Author.unsaved_triples.first[:subject].should == "http://bogus.org/ontology.owl#JimBob"
    Author.term.term.should == "http://bogus.org/ontology.owl#JimBob"
  end

  it "should create a new instance with the correct rdf_type" do
    nb = Book.new
    nb.unsaved_triples.first[:predicate].should == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    nb.unsaved_triples.first[:object].should == Book.term.term
  end
end
