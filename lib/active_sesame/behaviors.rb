module ActiveSesame::Behaviors

  module Ontology

    def self.mimic(klass, options={})
      defaults = {:repository => ActiveSesame::Repository.new, :ontology_attribute => :name}
      defaults.merge!(options)
      klass.send(:include, self)
      klass.repository = defaults[:repository]
      klass.ontology_attribute = defaults[:ontology_attribute]
      return klass
    end

    def self.included(klass)
      class << klass
        attr_accessor :ontology_attribute, :repository
      end

      klass.ontology_attribute = :name
      klass.repository =  ActiveSesame::Repository.new
      klass.class_eval do
        def self.set_ontology_attribute(value,&block)
          block_given? ? attribute_value = yield(value) : attribute_value = value
          self.ontology_attribute = value.to_sym
        end

        def self.set_repository(repository)
          self.repository = repository
        end
      end
    end

    def ontology
      @ontology ||= ActiveSesame::Ontology::Term.new(self.send(self.class.ontology_attribute), self.class.repository)
    end
  end

end
