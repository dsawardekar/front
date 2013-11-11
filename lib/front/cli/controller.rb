module Front
  module CLI
    require 'front/version'
    require 'front/loader'
    require_relative 'vagrant'
    require_relative 'vagrant_pool'

    class Controller
      include Loader
      attr_reader :options

      def initialize(options)
        @options = options
        @pool = VagrantPool.new(options.pool_size)
      end

      # actions
      def create
        @pool.create
        @pool.load
      end

      def destroy
        @pool.unload
      end

      def next
        @pool.next
      end

      def ssh
        @pool.ssh
      end

      def ssh_config
        puts @pool.ssh_config
      end

      def inventory
        puts File.read(@pool.get_inventory_file())
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
