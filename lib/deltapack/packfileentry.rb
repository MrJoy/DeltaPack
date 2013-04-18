module DeltaPack
  class PackFileEntry
    attr_reader :kind
    attr_reader :filename
    attr_reader :contents

    def initialize(kind, filename, contents)
      @kind = kind
      @filename = filename
      @contents = contents
    end
  end
end
