module Front
  module CLI
    require_relative 'configuration'
    require_relative 'router'

    class App
      def start(args)
        config = Configuration.new
        options = config.load(args)

        router = Router.new
        router.route(options)
      end
    end
  end
end
