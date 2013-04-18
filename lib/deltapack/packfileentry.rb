module DeltaPack
  class PackFileEntry
    def self.encode(previous_entry, src_filename, allowed_methods)
      if(previous_entry == nil)
        encoder = DeltaPack::Encoder.find_by_kind(:literal)
        contents = encoder.encode(nil, src_filename)
      else
        # TODO: Dynamically determine which encoder to use...
        basis = previous_entry.filename
        (contents, encoder) = allowed_methods.map do |kind|
          enc = DeltaPack::Encoder.find_by_kind(kind)
          [enc.encode(basis, src_filename), enc]
        end.sort do |a,b|
          a[0].length <=> b[0].length
        end.first
      end

      return PackFileEntry.new(encoder, src_filename, contents)
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
