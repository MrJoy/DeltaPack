require 'tempfile'

module DeltaPack
  class Encoder
    def initialize
      raise "Can't instantiate DeltaPack::Encoder directly" unless(defined? self.class::KIND)
    end

    def token
      self.class::KIND.to_s[0]
    end

    def kind
      self.class::KIND
    end

    protected

    def temp_dir
      return self.class.send(:temp_dir)
    end

    class << self
      def find_by_kind(kind)
        return @encoders_by_kind[kind]
      end

      def find_by_token(kind)
        return @encoders_by_token[kind]
      end

      def init!
        @encoders_by_kind = {}
        @encoders_by_token = {}
        (@raw_encoders || []).each do |encoder_class|
          encoder_instance = encoder_class.new
          encoder_kind = encoder_class::KIND
          @encoders_by_kind[encoder_kind] = encoder_instance
          @encoders_by_token[encoder_instance.token] = encoder_instance
        end

        collision_check = {}
        @encoders_by_kind.
          keys.
          map { |key| [key.to_s[0], key] }.
          each do |(token, key)|
            collision_check[token] ||= []
            collision_check[token] << key
          end

        has_error = false
        collision_check.map do |key, value|
          next if(value.length == 1)
          has_error = true
          STDERR.puts("Got a token collision ('#{key}') between encoders: #{value.join(', ')}")
        end
        raise "Cannot proceed with conflicting encoders." if(has_error)
      end

      protected

      def temp_dir
        @temp_dir ||= Dir.mktmpdir
      end

      def inherited(child_class)
        @raw_encoders ||= []
        @raw_encoders << child_class
      end

      attr_accessor :encoders_by_kind
      attr_accessor :encoders_by_token
      attr_accessor :raw_encoders
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'encoders', '**', '*.rb')).each do |fname|
  require fname
end

DeltaPack::Encoder.init!
