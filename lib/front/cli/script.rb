module Front
  module CLI
    class Script
      def initialize(path)
        @commands = []
        @path = path
      end

      def enqueue(cmd)
        @commands << cmd
      end

      def save
        File.open(@path, 'w') do |file|
          file.puts("#!/bin/bash")

          @commands.each do |command|
            file.puts(command)
          end
        end

        File.chmod(0755, @path)
      end

      def run
        if pending?
          save()
          pid = Kernel.spawn(@path)
          Process.detach pid
        end
      end

      def pending?
        @commands.length > 0
      end
    end
  end
end
