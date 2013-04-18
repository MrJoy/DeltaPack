module DeltaPack
  class PackFile
    def initialize(fname, mode, &block)
      raise "Mode must be one of :r, or :w." unless [:r, :w].include?(mode)
      raise "No such file #{fname}" if(mode == :r && !File.exists?(fname))

      File.open(fname, mode.to_s) do |fh|
        self.fh = fh
        if(mode == :w)
          fh.write("DPAK")
        end
        self.instance_eval &block
      end
    ensure
      self.fh = nil
    end

    protected

    attr_accessor :fh

    def append_file(entry)
      puts "Adding #{entry.filename}, with contents '#{entry.contents}', which is a #{entry.kind}..."
    end

    def read_file
    end
  end
end
