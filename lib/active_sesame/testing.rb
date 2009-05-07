module ActiveSesame
  module Testing
    require 'rest-open-uri'
    require 'uri'

      @@repository_uri = "http://localhost:8112/sesame/repositories"
      @@triple_store_id = "go-for-ryan"
      @@location = @@repository_uri + "/" + @@triple_store_id
      @@prefixes = ["PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>",
                    "PREFIX ss: <http://study-stash.radiology.umm.edu/ontologies/study-stash.owl#>",
                    "PREFIX owl: <http://www.w3.org/2002/07/owl#>",
		    "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
		    "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>"]

      def self.find_by_sparql(query, include_prefixes=true)
        #puts self.base_uri + " " + @@prefixes.join(" ") + " " + query
        rest_call("", :method => :get, :body => {:infer => "false", :queryLn => "SPARQL", :query => @@base + " " + @@prefixes.join(" ") + " " + query})
      end

      def self.group_save(xml)
        xml = "<transaction>#{xml}</transaction>"
	#puts xml
        rest_call("statements", {:method => :post, "content-type" => "application/x-rdftransaction", :body => xml})
      end

      def self.save_triple(subject, predicate, object)
        rest_call("statements", {:method => :put, :body => {:subj => subject, :pred => predicate, :obj => object}})
      end

      def self.delete_by_pattern(subject, predicate, object)
        rest_call("statements", {:method => :delete, :body => {:subj => subject, :pred => predicate, :obj => object}})
      end

      def self.triple_store_id
        @@triple_store_id
      end

      def self.set_triple_store_id(new_id)
        @@triple_store_id = new_id.to_s
      end

      def self.repository_uri
        @@repository_uri
      end

      def self.set_repository_uri(new_repository)
        @@repository_uri = new_repository
      end

      def self.prefixes
        @@prefixes
      end

      def self.add_prefix(prefix)
        @@prefixes << prefix
      end

      def self.base_uri
        uri_with_quacks = @@base.split(" ").last
	uri_with_quacks.slice(1,uri_with_quacks.length-2)
      end

#      def self.base_uri
#        uri_with_quacks = @@base.split(" ").last
#	uri_with_quacks.slice(1,uri_with_quacks.length-2)
#      end

      def self.set_base_uri(base_uri)
        @@base = "BASE <#{base_uri}>"
      end

      def self.simple_rest_methods(*method_names)
        method_names.each do |name|
	  new_name = "self.#{name.to_s}"
          define_method(new_name) { return rest_call(name) }
        end
      end

      self.simple_rest_methods :size, :contexts, :namespaces
      self.set_base_uri "http://www.geneontology.org/formats/oboInOwl"

      def self.rest_call(method_name, args={})
        args[:body][:query] = encode_sparql(args[:body][:query]) if args[:body][:query] if args[:body]
        args[:body][:subj] = encode_sparql(args[:body][:subj]) if args[:body][:subj] if args[:body]
        args[:body][:pred] = encode_sparql(args[:body][:pred]) if args[:body][:pred] if args[:body]
        args[:body][:obj] = encode_sparql(args[:body][:obj]) if args[:body][:obj] if args[:body]
        [:get, :put, :delete].include?(args[:method]) ? vars_if_get = hash_to_get(args[:body]) : vars_if_get = ""
        method_name == "" ? slash = "" : slash = "/"
	puts @@location + slash + method_name.to_s + vars_if_get
        puts self.repository_uri + "/" + self.triple_store_id + slash + method_name.to_s + vars_if_get
        return open(self.repository_uri + "/" + self.triple_store_id + slash + method_name.to_s + vars_if_get, args).read
      end

      def self.encode_sparql(query)
        URI.encode(query).gsub("?","%3f").gsub("/","%2f").gsub(":","%3a").gsub("\\","5C")
      end

      def self.hash_to_get(hash)
        (hash.inject("?") {|total,tuple| total += "#{tuple[0]}=#{tuple[1]}&"}).chop
      end


    end



end
