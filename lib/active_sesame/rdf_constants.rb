module ActiveSesame::RDFConstants
  def self.literal_to_proc_hash
    {
      "http://www.w3.org/2001/XMLSchema#string" => :to_s,
      "http://www.w3.org/2001/XMLSchema#dateTime" => :to_time,
      "http://www.w3.org/2001/XMLSchema#int" => :to_i
    }
  end

  def self.literals
    [
     "http://www.w3.org/2001/XMLSchema#string",
     "http://www.w3.org/2001/XMLSchema#int",
     "http://www.w3.org/2001/XMLSchema#dateTime",
    ]
  end

  def self.class_to_match_hash
    {
      String => "xsd:string",
      Time => "xsd:dateTime",
      Date => "xsd:date",
      Fixnum => "xsd:integer"
    }
  end

  def self.class_to_literal
    {
      String => "http://www.w3.org/2001/XMLSchema#string",
      Time => "http://www.w3.org/2001/XMLSchema#dateTime",
      Date => "http://www.w3.org/2001/XMLSchema#date",
      Fixnum => "http://www.w3.org/2001/XMLSchema#int"
    }
  end

  def self.prefixes
    {
      :xsd => "http://www.w3.org/2001/XMLSchema",
      :owl => "http://www.w3.org/2002/07/owl",
      :rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns",
      :rdfs => "http://www.w3.org/2000/01/rdf-schema",
    }
  end

  def self.uri_to_prefix(uri, additional_uris={})
    uri_prefix, term = uri.split("#","")
    uri_prefixes = self.prefixes.merge(additional_uris)
    if term and uri_prefixes.has_key?(uri_without_pound)
      uri_prefixes[uri_without_pound] + ":" + term
    else
      uri
    end
  end
end

