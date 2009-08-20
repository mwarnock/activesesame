module ActiveSesame
  module MonkeyPatches
    Array.class_eval do
      def all
        self
      end
    end

    Hash.class_eval do
      def to_triple
        ActiveSesame::Triple.new(self)
      end
    end
  end
end
