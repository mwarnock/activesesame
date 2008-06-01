module ActiveSesame
  module Support
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
  end
end
