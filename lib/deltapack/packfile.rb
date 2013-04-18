module DeltaPack
  class PackFile
    def initialize(fname, mode, allowed_methods = [], &block)
      raise "Mode must be one of :r, or :w." unless [:r, :w].include?(mode)
      raise "No such file #{fname}" if(mode == :r && !File.exists?(fname))

      @allowed_methods = allowed_methods
      if(mode == :w)
        fmode = "wb"
      else
        fmode = "rb"
      end

      File.open(fname, fmode) do |fhandle|
        @fh = fhandle
        if(mode == :w)
          @fh.write("DPAK")
        else
          header = @fh.read(4)
          raise "This is not a DeltaPack file.  Terminating." if(header != "DPAK")
        end
        self.instance_eval &block
      end
    ensure
      @fh = nil
    end

    protected

    attr_accessor :fh
    attr_accessor :last_entry
    attr_accessor :allowed_methods

    def append_file(fname)
      entry = DeltaPack::PackFileEntry.encode(@last_entry, fname, allowed_methods)
      fname = File.basename(entry.filename)

      puts "Adding #{fname}, using method: #{entry.encoder.kind} (#{entry.contents.length} bytes)"
      @fh.write([
        entry.encoder.token,
        fname.length,
        fname,
        entry.contents.length,
        entry.contents
      ].pack('ACA*L>A*'))
      @last_entry = entry
    end

    def read_file
      begin
        token = @fh.read(1)
        return false if(token.nil?)
        name_length = @fh.read(1).ord
        filename = @fh.read(name_length)
        content_length = @fh.read(4).unpack("L>").first
        contents = @fh.read(content_length)
        entry = DeltaPack::PackFileEntry.decode(@last_entry, filename, token, contents)
        @last_entry = entry
        return entry
      # rescue
      #   return false
      end
    end
  end
end
