module Front
  module CLI
    require 'optparse'
    require 'ostruct'

    class Configuration
      include Loader

      def load(args)
        options = OpenStruct.new
        options.action = nil
        options.error = nil
        options.pool_size = 2

        parse(args, options)
      end

      def get_parser(args, options)
        OptionParser.new do |opts|
          options.opts = opts
          opts.banner = 'Usage: front [options] [action]'
          opts.separator ''
          opts.separator 'Actions'
          opts.separator '  create     : create a new pool'
          opts.separator '  destroy    : destroy pool'
          opts.separator '  next       : switch to next instance in pool'
          opts.separator '  ssh        : ssh to current instance => vagrant ssh'
          opts.separator '  ssh_config : print ssh config for current instance'
          opts.separator '  inventory  : print inventory file (for ansible)'
          opts.separator ''
          opts.separator 'Options'
          opts.separator ''

          opts.on('-s', '--size <size>', Integer, 'Size of instance pool') do |pool_size|
            options.pool_size = pool_size
          end

          opts.on_tail('-V', '--version', 'Print Front version') do
            options.action = :show_version
          end

          opts.on_tail('-h', '--help', 'Print Front help') do
            options.action = :show_help
          end
        end
      end

      def parse(args, options)
        parser = get_parser(args, options)

        begin
          parser.parse!(args)
          if options.action.nil?
            if args.length == 1
              options.action = args[0]
            else
              raise OptionParser::InvalidOption.new(args)
            end
          end
        rescue OptionParser::InvalidOption => err
          options.error = err
          options.action = :show_invalid_option
        rescue OptionParser::MissingArgument => err
          options.error = err
          options.action = :show_missing_args
        rescue OptionParser::ParseError => err
          options.error = err
          options.action = :show_parser_error
        end

        options
      end
    end
  end
end
