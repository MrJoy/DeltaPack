module DeltaPack
  module Encoders
    class XDelta < DeltaPack::Encoder
      KIND = :xdelta

      def encode(basis, target)
        tmp = File.join(self.temp_dir, "xdelta.tmp")
        begin
          result = system(
            "xdelta3",
            "encode",
            "-s",
            basis,
            target,
            tmp
          )
          result = IO.binread(tmp) if(result)

          return result
        ensure
          File.unlink(tmp)
        end
      end

      def decode(basis, delta)
        tmp = File.join(self.temp_dir, "xdelta.tmp")
        begin
          result = system(
            "xdelta3",
            "decode",
            "-s",
            basis,
            delta,
            tmp
          )
          result = IO.binread(tmp) if(result)

          return result
        ensure
          File.unlink(tmp)
        end
      end
    end
  end
end
