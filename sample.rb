#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'deltapack'))

allowed_methods = ARGV.map(&:to_sym)

Dir.glob('samples/*').sort.each do |dir|
  DeltaPack::PackFile.new("#{File.basename(dir)}.dpack", :w, allowed_methods) do
    Dir.glob("#{dir}/*.json").sort.each do |fname|
      append_file fname
    end
  end
end

# DeltaPack::PackFile.new("foo.dpack", :r) do
#   while(entry = read_file)
#     dst_filename = File.join("tmp", entry.filename)
#     puts "Writing '#{dst_filename}' (#{entry.contents.length} bytes), was encoded with method: #{entry.encoder.kind}"
#     IO.binwrite(dst_filename, entry.contents)
#   end
# end
