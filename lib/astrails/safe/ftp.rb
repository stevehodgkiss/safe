module Astrails
  module Safe
    class Ftp < Sink

      protected

      def active?
        host && user
      end

      def path
        @path ||= expand(config[:ftp, :path] || config[:local, :path] || ":kind/:id")
      end

      def save
        raise RuntimeError, "pipe-streaming not supported for ftp." unless @backup.path

        puts "Uploading #{host}:#{full_path} via ftp" if $_VERBOSE || $DRY_RUN
        require 'pathname'
        
        unless $DRY_RUN || $LOCAL
          opts = {}
          opts[:password] = password if password
          opts[:port] = port if port
          Net::FTP.open(host, user, opts[:password]) do |ftp|
            begin
              puts "Sending #{@backup.path} to #{full_path}" if $_VERBOSE
              ftp.putbinaryfile @backup.path, full_path
            rescue Net::FTPPermError
              puts "Ensuring remote path (#{path}) exists" if $_VERBOSE
              ftp.mkdir Pathname.new(full_path).dirname.to_s
              retry
            end
          end
          puts "...done" if $_VERBOSE
        end
      end

      def cleanup
        return if $LOCAL || $DRY_RUN

        return unless keep = @config[:keep, :ftp]
        
        puts "cleanup not implemented"
        return
      end

      def host
        @config[:ftp, :host]
      end

      def user
        @config[:ftp, :user]
      end

      def password
        @config[:ftp, :password]
      end

      def port
        @config[:ftp, :port]
      end

    end
  end
end