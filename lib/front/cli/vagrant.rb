module Front
  module CLI
    class Vagrant
      attr_reader :id
      attr_reader :path
      attr_accessor :wait

      def initialize(id, path)
        @id = id
        @path = path
        @wait = true
      end

      def up
        run('vagrant up')
      end

      def destroy
        run('vagrant destroy -f')
      end

      def reload
        run('vagrant reload')
      end

      def ssh
        run('vagrant ssh')
      end

      def ssh_config
        Dir.chdir(path) do
          `vagrant ssh-config`
        end
      end

      def ssh_port
        output = ssh_config()
        re = /^\s*Port\s*(\d+)$/m

        matches = output.match(re)
        return matches[1]
      end

      def run(cmd)
        options = {}
        options[:chdir] = path
        unless wait
          log_file = "#{path}/front.log"
          options[:out] = log_file
          options[:err] = log_file
        end

        pid = Kernel.spawn(cmd, options)
        if wait
          Process.wait pid
        else
          Process.detach pid
        end
      end
    end
  end
end
