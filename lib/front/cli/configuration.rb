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
        options.pool_size = 4

        parse(args, options)
      end

      def get_parser(args, options)
        OptionParser.new do |opts|
          options.opts = opts
          opts.banner = 'Usage: front [options] [create|destroy|next|ssh|ssh_config|inventory]'
          opts.separator ''
          opts.separator 'Options'
          opts.separator ''

          opts.on('-s', '--size <size>', Integer, 'Size of instance pool') do |pool_size|
            options.pool_size = pool_size
          end
        end
      end

      def parse(args, options)
        parser = get_parser(args, options)

        begin
          parser.parse!(args)
          if args.length == 1
            options.action = args[0]
          else
            raise OptionParser::InvalidOption.new(args)
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
