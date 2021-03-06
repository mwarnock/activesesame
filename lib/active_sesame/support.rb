module ActiveSesame
  module Support

    #Think about changing to a uri class rather than manipulating strings...
    def self.property_to_constant(prop)
      prop = prop.to_s
      prop = ResultParser.uri_to_sym(prop) if prop.match(/#/) 
      prop.first.upcase + prop.slice(1,prop.length)
    end

    def self.uri_to_sym(uri)
      uri.split("#")[1].to_sym
    end

    def self.encode_whitespace(string)
      string.gsub(" ","%20")
    end

    def self.uncode_whitespace(string)
      return string.class == String ? string.gsub("%20"," ") : string
    end

    def is_uri?(string)
      if string.class == String
        string =~ /^http:\/\//
      else
        false
      end
    end

    def uri_to_prefix(uri, additional_uris={})
      uri_prefix, term = uri.split("#")
      uri_prefixes = ActiveSesame::RDFConstants.prefixes.merge(additional_uris)
      uri_prefixes = uri_prefixes.keys.inject(Hash.new) {|hash,key| hash[uri_prefixes[key]] = key; hash} #reverse key and value
      #puts "\n" + uri_prefixes.inspect + "\n"
      if uri_prefixes.has_key?(uri_prefix)
        uri_prefixes[uri_prefix]
      else
        uri_prefix
      end
    end

    def method_from_uri(uri, additional_uris={})
      #puts "uris for doober: #{additional_uris.inspect}"
      #puts "uri to be transformed to method #{uri}"
      #puts "method generated: #{self.uri_to_prefix(uri, additional_uris)}"
      uri_prefix = self.uri_to_prefix(uri, additional_uris)
      bogus, term = uri.split("#")
      term ? "#{uri_prefix}_#{term}" : uri_prefix
    end

    def expand_triples(triple_list, additional_uris={})
      #puts "\n#{additional_uris.inspect}\n"
      triple_list.collect {|triple| expand_triple(triple, additional_uris) }
    end

    def expand_triple(triple, additional_uris={})
      #puts "\n#{additional_uris.inspect}\n"
      triple.keys.inject(Hash.new) {|hash,key| hash[key] = expand_term(triple[key], additional_uris); hash }
    end

    def expand_terms(term_list, additional_uris={})
      #puts "\n#{additional_uris.inspect}\n"
      term_list.collect {|term| self.expand_term(term) }
    end

    def expand_term(full_term, additional_uris={})
      #puts "\n#{additional_uris.inspect}\n"
      prefix, term = full_term.split(":")
      (term != nil and not is_uri?(full_term)) ? expand_prefix(prefix, additional_uris) + "#" + term : full_term
    end

    def expand_prefix(prefix, additional_uris={})
      #puts "\n#{additional_uris.inspect}\n"
      if additional_uris.has_key?(prefix)
        additional_uris[prefix]
      else
        throw "Invalid Prefix: the prefix \"#{prefix}\" was not found in #{additional_uris.inspect}"
      end
    end

  end

  class Triple
    attr_accessor :hash

    def self.triple_components
      [:subject, :object, :predicate]
    end

    def method_missing(method, *args, &block)
      if self.hash.has_key?(method)
        self.hash[method]
      else
        super(method, *args, &block)
      end
    end

    def initialize(real_hash={})
      self.hash = real_hash.keys.inject(Hash.new) {|hash,key| hash[key.to_sym] = real_hash[key] if self.class.triple_components.include?(key.to_sym); hash }
      unless self.hash.has_key?(:subject) and self.hash.has_key?(:object) and self.hash.has_key?(:predicate)
        raise "Not a valid triple: missing subject, object, or predicate"
      end
    end

    def to_hash
      self.hash
    end

    def to_triple
      self
    end
  end
end
