module ActiveSesame
  module RDFConstants
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
       Fixnum => "http://www.w3.org/2001/XMLSchema#int"
      }
    end
  end
end
