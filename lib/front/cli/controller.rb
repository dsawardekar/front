module Front
  module CLI
    require 'front/version'

    class Controller
      def initialize(options)
        @options = options
      end

      # actions
      def create
      end

      def destroy
      end

      def next
      end

      def ssh
      end

      def ssh_config
      end

      def inventory
      end

      # errors
      def show_invalid_option
        show_error @options.error
      end

      def show_missing_args
        show_error @options.error
      end

      def show_parser_error
        show_error @options.error
      end

      def show_error(msg = @options.error)
        puts "Error: #{msg}"
        puts

        show_help
      end

      def method_missing(method)
        show_error "Unknown action: #{method}"
      end

      # help
      def show_help
        puts @options.opts
      end
    end
  end
end
