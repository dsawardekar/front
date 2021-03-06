module Front
  module CLI
    class Vagrant
      attr_reader :id
      attr_reader :path
      attr_accessor :wait
      attr_accessor :script

      def initialize(id, path, script)
        @id = id
        @path = path
        @wait = true
        @script = script
      end

      def up
        run('up')
      end

      def destroy
        run('destroy -f')
      end

      def reload
        run('reload')
      end

      def ssh
        run('ssh')
      end

      def ssh_config
        capture('ssh-config')
      end

      def ssh_port
        output = ssh_config()
        re = /^\s*Port\s*(\d+)$/m

        matches = output.match(re)
        return matches[1] unless matches.nil?
        return '2222'
      end

      def status
        output = capture('status')
        re = /^(\w+\s+\w+ \(\w+\))/m
        matches = output.match(re)
        if matches
          return matches[1]
        else
          'pending'
        end
      end

      def get_log_file
        "#{path}/front.log"
      end

      def run(cmd)
        cmd = "vagrant #{cmd}"
        options = {}
        options[:chdir] = path

        if wait
          pid = Kernel.spawn(cmd, options)
          Process.wait pid
        else
          cmd = "#{cmd} &>> #{get_log_file()} "
          script.enqueue "cd #{path} && #{cmd}"
        end
      end

      def capture(cmd)
        Dir.chdir(path) do
          `vagrant #{cmd}`
        end
      end
    end
  end
end
