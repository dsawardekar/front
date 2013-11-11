module Front
  module CLI
    require 'fileutils'
    require 'json'

    class VagrantPool
      include Loader
      attr_reader :size

      def initialize(size)
        @size = size
      end

      def create
        front_path = get_front_path()
        FileUtils.mkdir_p(front_path)

        size.times do |index|
          instance_id = index + 1
          instance_path = get_instance_path(instance_id)

          FileUtils.mkdir_p(instance_path)
          FileUtils.cp get_vagrant_file(), instance_path
        end

        create_front_file
      end

      def load
        loaded = false
        size.times do |index|
          instance_id = index + 1
          instance_path = get_instance_path(instance_id)

          vagrant = Vagrant.new(instance_id, instance_path)
          vagrant.wait = !loaded
          vagrant.up

          loaded = true
        end
      end

      def unload
        size.times do |index|
          instance_id = index + 1
          instance_path = get_instance_path(instance_id)

          vagrant = Vagrant.new(instance_id, instance_path)
          vagrant.destroy
        end

        FileUtils.rm_rf(get_front_path())
      end

      def next
        current_id = get_current_id()
        vagrant = get_vagrant(current_id)
        vagrant.wait = false
        vagrant.reload

        next_id = get_next_id()
        vagrant = get_vagrant(next_id)
        puts "Switched to instance \##{next_id}"

        save_front_file(next_id)
        update_inventory(vagrant)
        next_id
      end

      def ssh
        vagrant = get_vagrant(get_current_id())
        vagrant.ssh
      end

      def ssh_config
        vagrant = get_vagrant(get_current_id())
        vagrant.ssh_config
      end

      def get_vagrant(instance_id)
        instance_path = get_instance_path(instance_id)
        Vagrant.new(instance_id, instance_path)
      end

      def get_inventory_file
        "#{get_front_path()}/inventory.ini"
      end

      def get_front_path
        "#{Dir.pwd}/.front"
      end

      def get_instance_path(id)
        "#{get_front_path()}/#{id}"
      end

      def get_vagrant_file
        custom_path = "#{Dir.pwd}/Vagrantfile"
        if File.exists?(custom_path)
          return custom_path
        else
          return "#{ROOT_DIR}/Vagrantfile"
        end
      end

      def get_front_file
        "#{get_front_path()}/Frontfile"
      end

      def get_front_json
        JSON.parse(IO.read(get_front_file()))
      end

      def get_current_id
        json = get_front_json
        json['current']
      end

      def get_next_id
        current_id = get_current_id()
        if current_id + 1 > size
          next_id = 1
        else
          next_id = current_id + 1
        end

        next_id
      end

      # helpers
      def create_front_file
        path = get_front_file()
        hash = { 'current' => 1 }

        File.open(path, 'w') do |file|
          file.write(hash.to_json)
        end
      end

      def save_front_file(current)
        json = get_front_json()
        json['current'] = current

        File.open(get_front_file, 'w') do |file|
          file.write(json.to_json)
        end
      end

      def update_inventory(vagrant)
        ip_address = '127.0.0.1'
        port = vagrant.ssh_port()

        item = "#{ip_address}:#{port}"
        File.open(get_inventory_file(), 'w') do |file|
          file.write(item)
        end
      end
    end
  end
end
