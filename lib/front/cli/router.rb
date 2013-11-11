module Front
  module CLI
    require_relative 'controller'

    class Router
      def route(options)
        controller = Controller.new(options)
        controller.send(options.action)
      end
    end
  end
end
