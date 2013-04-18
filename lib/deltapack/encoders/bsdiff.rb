module DeltaPack
  module Encoders
    class BSDiff < DeltaPack::Encoder
      KIND = :bsdiff

      def encode(basis_name, target_name)
        delta_name = File.join(self.temp_dir, "bsdiff.tmp")
        begin
          result = system(
            "bsdiff",
            basis_name,
            target_name,
            delta_name
          )
          result = IO.binread(delta_name) if(result)

          return result
        ensure
          File.unlink(delta_name)
        end
      end

      def decode(basis_contents, delta_contents)
        begin
          basis_name = File.join(self.temp_dir, "bsdiff.basis")
          IO.binwrite(basis_name, basis_contents)
          delta_name = File.join(self.temp_dir, "bsdiff.delta")
          IO.binwrite(delta_name, delta_contents)
          target_name = File.join(self.temp_dir, "bsdiff.target")

          result = system(
            "bspatch",
            basis_name,
            target_name,
            delta_name
          )
          result = IO.binread(target_name) if(result)

          return result
        ensure
          File.unlink(target_name) rescue nil
          File.unlink(basis_name) rescue nil
          File.unlink(delta_name) rescue nil
        end
      end
    end
  end
end
