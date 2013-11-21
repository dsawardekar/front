module Front
  module CLI
    require 'fileutils'
    require_relative 'front_file'
    require_relative 'script'

    class VagrantPool
      include Loader

      def initialize(size)
        @size = size
        @script = Script.new(get_script_path())
      end

      def create
        front_path = get_front_path()
        FileUtils.mkdir_p(front_path)

        get_pool_size().times do |index|
          instance_id = index + 1
          instance_path = get_instance_path(instance_id)

          FileUtils.mkdir_p(instance_path)
          FileUtils.cp get_vagrant_file(), instance_path
        end

        create_front_file
      end

      def load
        loaded = false
        first_vagrant = nil
        get_pool_size().times do |index|
          vagrant = get_vagrant(index + 1)
          vagrant.wait = !loaded
          vagrant.up

          unless loaded
            first_vagrant = vagrant
          end

          loaded = true
        end

        update_inventory(first_vagrant)
        @script.run
      end

      def unload
        get_pool_size().times do |index|
          instance_id = index + 1
          vagrant = get_vagrant(instance_id)
          puts "Destroying instance \##{instance_id}"
          vagrant.destroy
        end

        FileUtils.rm_rf(get_front_path())
      end

      def next
        current_id = get_current_id()
        vagrant = get_vagrant(current_id)
        vagrant.wait = false
        vagrant.destroy
        vagrant.up

        next_id = get_next_id()
        vagrant = get_vagrant(next_id)
        puts "Switched to instance \##{next_id}"

        save_front_file(next_id)
        update_inventory(vagrant)
        @script.run()

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

      def status
        current_id = get_current_id()
        get_pool_size().times do |index|
          instance_id = index + 1
          if instance_id == current_id
            instance_label = "\##{instance_id}*"
          else
            instance_label = "\##{instance_id} "
          end

          vagrant = get_vagrant(instance_id)
          puts "Instance #{instance_label}: #{vagrant.status}"
        end
      end

      def get_vagrant(instance_id)
        instance_path = get_instance_path(instance_id)
        Vagrant.new(instance_id, instance_path, @script)
      end

      def get_inventory_file
        "#{get_front_path()}/inventory.ini"
      end

      def get_front_path
        "#{Dir.pwd}/.front"
      end

      def get_script_path
        "#{get_front_path()}/pending.sh"
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

      def get_frontfile_path
        "#{get_front_path()}/Frontfile"
      end

      def get_current_id
        get_front_file().get_current_id()
      end

      def get_next_id
        current_id = get_current_id()
        if current_id + 1 > get_pool_size()
          next_id = 1
        else
          next_id = current_id + 1
        end

        next_id
      end

      def get_pool_size
        front_file = get_front_file()
        if front_file.exists?
          front_file.get_pool_size()
        else
          @size
        end
      end

      # helpers
      def get_front_file
        if @front_file.nil?
          @front_file = Frontfile.new(get_frontfile_path())
          if @front_file.exists?
            @front_file.load()
          end
        end

        @front_file
      end

      def create_front_file
        defaults = {}
        defaults['current_id'] = 1
        defaults['pool_size'] = @size

        front_file = get_front_file()
        front_file.create(defaults)
      end

      def save_front_file(current_id)
        front_file = get_front_file()
        front_file.set_current_id(current_id)
        front_file.save()
      end

      def update_inventory(vagrant)
        ip_address = "127.0.0.#{get_current_id()}"
        port = vagrant.ssh_port()

        item = "#{ip_address}:#{port}"
        File.open(get_inventory_file(), 'w') do |file|
          file.write(item)
        end
      end
    end
  end
end
