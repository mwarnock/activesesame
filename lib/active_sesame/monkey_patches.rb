module ActiveSesame
  module MonkeyPatches
    Array.class_eval do
      def all
        self
      end
    end
  end
end
