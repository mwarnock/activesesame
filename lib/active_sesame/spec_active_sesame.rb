require 'active_sesame'

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

  describe ActiveSesame::Repository do
    it "should connect to a triple store" do
      ActiveSesame::Repository.new
    end
  end

  describe ActiveSesame::Behaviors do
    describe ActiveSesame::Behaviors::Ontology do
      before do
        class TermTest
          attr_accessor :name
          include ActiveSesame::Behaviors::Ontology
          set_ontology_attribute :name
        end
        @term = TermTest.new
        @term.name = "http://www.owl-ontologies.com/Ontology1241733063.owl#RID3436"
      end

      it "should bootstrap the class" do
        @term.respond_to?(:ontology).should be_true
        @term.ontology.term.should be_equal(@term.send(@term.class.ontology_attribute))
      end

      it "should have relationships" do
        @term.ontology.relationships.keys.size.should_not be_equal(0)
      end

      it "'s relationships should include an ontology term" do
        @term.ontology.Is_A.class.should == ActiveSesame::Ontology::Term
      end

    end

    it "should make a sparql query" do
      ActiveSesame::Behaviors::FuzzyOntology.include_fuzzy_ontology(self, :bogus).should_not be_equal(nil)
    end
  end

  describe ActiveSesame::ResultParser do
  end


  describe ActiveSesame::Base do
  end
end
