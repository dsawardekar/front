module Front
  module CLI
    require 'json'

    class Frontfile
      attr_reader :path
      attr_reader :data

      def initialize(path)
        @path = path
      end

      def exists?
        File.exists?(path)
      end

      def create(defaults)
        @data = defaults
        save()
      end

      def load
        file_contents = File.read(path)
        @data = JSON.parse(file_contents)
      end

      def save
        json = @data.to_json
        File.open(path, 'w') do |file|
          file.write(json)
        end
      end

      def get_current_id
        @data['current_id']
      end

      def set_current_id(current_id)
        @data['current_id'] = current_id
      end

      def get_pool_size
        @data['pool_size']
      end

      def set_pool_size(pool_size)
        @data['pool_size'] = pool_size
      end
    end
  end
end
