module ActiveSesame
  class Repository

    @@prefixes = {"xsd" => "http://www.w3.org/2001/XMLSchema#",
      "ss" => "http://study-stash.radiology.umm.edu/ontologies/study-stash.owl",
      "owl" => "http://www.w3.org/2002/07/owl",
      "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns",
      "rdfs" => "http://www.w3.org/2000/01/rdf-schema"}

    attr_accessor :triple_store_id, :repository_uri, :repository_location, :base_uri, :connector, :prefixes

    def initialize(repository_type=SesameProtocol, options={})
      self.send(:extend, repository_type)
      options = default_options.merge(options)
      options.each {|key,value| send("#{key}=".to_sym, value) if respond_to?(key) }
      self.prefixes = @@prefixes
    end

    def find_by_sparql(query, include_prefixes=true)
      query_dispatch("", :method => :get, :body => {:query => self.sparql_base + " " + self.prefixes_to_sparql + " " + query, :queryLn => "SPARQL"})
    end

    def find(query, include_prefixes=true)
      ActiveSesame::ResultParser.tableize(find_by_sparql(query, include_prefixes))
    end

    def group_save(xml)
      query_dispatch("statements", {:method => :post, "content-type" => "application/x-rdftransaction", :body => xml})
    end

    def save_triple(subject, predicate, object)
      query_dispatch("statements", {:method => :put, :body => {:subj => subject, :pred => predicate, :obj => object}})
    end

    def delete_by_pattern(subject, predicate, object)
      query_dispatch("statements", {:method => :delete, :body => {:subj => subject, :pred => predicate, :obj => object}})
    end

    def add_prefix(prefix, uri)
      self.prefixes = self.prefixes.merge({prefix => uri})
    end

    def add_prefixes(prefix_hash)
      self.prefixes = self.prefixes.merge(prefix_hash)
    end

    def sparql_base
      "BASE <#{base_uri}>"
    end

    def prefixes_to_sparql
      self.prefixes.keys.inject("") {|sparql,key| sparql += "PREFIX #{key}: <#{self.prefixes[key]}> " }
    end

  end

  module SesameProtocol
    require 'rest-open-uri'
    require 'uri'

    def self.extended(klass)
      simple_rest_methods :size, :contexts, :namespaces
    end

    def query_dispatch(method_name, args={})
      args[:body][:query] = encode_sparql(args[:body][:query]) if args[:body][:query] if args[:body]
      args[:body][:subj] = encode_sparql(args[:body][:subj]) if args[:body][:subj] if args[:body]
      args[:body][:pred] = encode_sparql(args[:body][:pred]) if args[:body][:pred] if args[:body]
      args[:body][:obj] = encode_sparql(args[:body][:obj]) if args[:body][:obj] if args[:body]
      [:get, :put, :delete].include?(args[:method]) ? vars_if_get = hash_to_get(args[:body]) : vars_if_get = ""
      method_name == "" ? slash = "" : slash = "/"
      return open(self.repository_uri + "/" + self.triple_store_id + slash + method_name.to_s + vars_if_get, args).read
    end

    def self.simple_rest_methods(*method_names)
      method_names.each do |name|
        new_name = name.to_s
        define_method(new_name) { return query_dispatch(name) }
      end
    end

    private
    def encode_sparql(query)
      URI.encode(query).gsub("?","%3f").gsub("/","%2f").gsub(":","%3a").gsub("\\","5C")
    end

    def hash_to_get(hash)
      (hash.inject("?") {|total,tuple| total += "#{tuple[0]}=#{tuple[1]}&"}).chop
    end

    def default_options
      {
        :repository_uri => "http://localhost:8111/sesame/repositories",
        :triple_store_id => "test",
        :location => "http://localhost:8111/sesame/repositories/test",
        :query_language => "SPARQL",
        :base_uri => "http://www.fakeontology.org/ontology.owl"
      }
    end

  end

end
