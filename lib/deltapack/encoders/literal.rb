module DeltaPack
  module Encoders
    class Literal < DeltaPack::Encoder
      KIND = :literal

      def encode(basis_name, target_name)
        return IO.binread(target_name)
      end

      def decode(basis_contents, delta_contents)
        return delta_contents
      end
    end
  end
end
