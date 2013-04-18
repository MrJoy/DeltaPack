module DeltaPack
  class PackFile
    def initialize(fname, mode, &block)
      raise "Mode must be one of :r, or :w." unless [:r, :w].include?(mode)
      raise "No such file #{fname}" if(mode == :r && !File.exists?(fname))

      if(mode == :w)
        fmode = "wb"
      else
        fmode = "rb"
      end

      File.open(fname, fmode) do |fh|
        self.fh = fh
        if(mode == :w)
          fh.write("DPAK")
        else
          header = fh.read(4)
          raise "This is not a DeltaPack file.  Terminating." if(header != "DPAK")
        end
        self.instance_eval &block
      end
    ensure
      self.fh = nil
    end

    protected

    attr_accessor :fh
    attr_accessor :last_entry

    def append_file(fname)
      entry = DeltaPack::PackFileEntry.encode(@last_entry, fname)
      fname = File.basename(entry.filename)

      puts "Adding #{fname}, using method: #{entry.encoder.kind} (#{entry.contents.length} bytes)"
      fh.write([
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
        token = fh.read(1)
        name_length = fh.read(1).ord
        filename = fh.read(name_length)
        content_length = fh.read(4).unpack("L>").first
        contents = fh.read(content_length)
        entry = DeltaPack::PackFileEntry.decode(@last_entry, filename, token, contents)
        @last_entry = entry
        return entry
      rescue
        return false
      end
    end
  end
end
