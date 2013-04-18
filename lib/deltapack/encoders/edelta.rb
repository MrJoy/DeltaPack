module DeltaPack
  module Encoders
    class EDelta < DeltaPack::Encoder
      KIND = :edelta

      def encode(basis, target)
        tmp = File.join(self.temp_dir, "edelta.tmp")
        begin
          result = system(
            "edelta",
            "-q",
            "delta",
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
        tmp = File.join(self.temp_dir, "edelta.tmp")
        begin
          result = system(
            "edelta",
            "-q",
            "patch",
            basis,
            tmp,
            delta
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
