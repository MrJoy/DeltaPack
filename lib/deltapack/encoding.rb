module DeltaPack
  class Encoding
    def self.find_encoder(kind)
      return @encoders[kind]
    end

    def self.inherited(child_class)
      @raw_encoders ||= []
      @raw_encoders << child_class
    end

    def self.init!
      @encoders = {}
      (@raw_encoders || []).each do |encoder_class|
        encoder_instance = encoder_class.new
        encoder_kind = encoder_class::KIND
        puts "Got: #{encoder_kind} => #{encoder_instance}"
        @encoders[encoder_kind] = encoder_instance
      end
    end

    protected

    class << self
      attr_accessor :encoders
      attr_accessor :raw_encoders
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'encoders', '**', '*.rb')).each do |fname|
  require fname
end

DeltaPack::Encoding.init!
