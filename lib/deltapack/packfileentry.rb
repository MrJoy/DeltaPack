module DeltaPack
  class PackFileEntry
    def self.encode(previous_entry, src_filename)
      if(previous_entry == nil)
        encoder = DeltaPack::Encoder.find_by_kind(:literal)
        basis = nil
      else
        # TODO: Dynamically determine which encoder to use...
        encoder = DeltaPack::Encoder.find_by_kind(:literal)
        basis = previous_entry.filename
      end
      filename = File.basename(src_filename)
      contents = encoder.encode(basis, src_filename)

      return PackFileEntry.new(encoder, filename, contents)
    end

    def self.decode(previous_entry, dst_filename, token, delta)
      encoder = DeltaPack::Encoder.find_by_token(token)
      if(previous_entry.nil?)
        basis = nil
      else
        basis = previous_entry.contents
      end
      contents = encoder.decode(basis, delta)
      return PackFileEntry.new(encoder, dst_filename, contents)
    end

    attr_reader :encoder
    attr_reader :filename
    attr_reader :contents

    def initialize(encoder, filename, contents)
      @encoder = encoder
      @filename = filename
      @contents = contents
    end
  end
end
