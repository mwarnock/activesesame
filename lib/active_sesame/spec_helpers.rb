module SpecHelpers
  def self.triples_to_add
    [
     {:subject => "base:Book", :predicate => "rdfs:subClassOf", :object => "owl:Thing"},
     {:subject => "base:Enders_Game", :predicate => "rdfs:subClassOf", :object => "base:Book"},
     {:subject => "base:Enders_Game", :predicate => "base:author", :object => "Orson Scott Card"},
     {:subject => "base:Enders_Game", :predicate => "base:title", :object => "Ender's Game"},
     {:subject => "base:Speaker_For_The_Dead", :predicate => "base:title", :object => "Speaker for the Dead"},
     {:subject => "base:Speaker_For_The_Dead", :predicate => "base:author", :object => "Orson Scott Card"},
     {:subject => "base:Speaker_For_The_Dead", :predicate => "base:title", :object => "base:Book"},
     {:subject => "base:Christmas_Carol", :predicate => "base:title", :object => "A Christmas Carol"},
     {:subject => "base:Christmas_Carol", :predicate => "base:author", :object => "Charles Dickens"},
     {:subject => "base:Christmas_Carol", :predicate => "rdfs:subClassOf", :object => "base:Book"}
    ].collect {|triple| triple.keys.inject(Hash.new) {|hash,key| hash[key] = expand_term(triple[key]); hash } }
  end

  def self.expand_term(full_term)
    prefix, term = full_term.split(":")
    term != nil ? expand_prefix(prefix) + "#" + term : prefix
  end

  def self.expand_prefix(prefix)
    {
      :xsd => "http://www.w3.org/2001/XMLSchema",
      :owl => "http://www.w3.org/2002/07/owl",
      :rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns",
      :rdfs => "http://www.w3.org/2000/01/rdf-schema",
      :base => "http://www.fakeontology.org/ontology.owl"
    }[prefix.to_sym]
  end
end
