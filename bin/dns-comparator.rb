require 'thor'

require_relative '../lib/dns-comparator'

class CLI < Thor
  class_option :verbose, default: false, type: :boolean , aliases: '-v'

  desc 'hosts -f FILE 8.8.8.8 8.8.4.4', 'Resolve hosts file to ips'
  method_option :file, required: true, aliases: '-f', desc: 'Resolve a hosts file'
  def hosts(*nameservers)
    @resolver = Resolver.new(nameservers)

    results = File.readlines(options[:file]).map do |line|
      @resolver.resolve(*line.split)
    end

    Printer.print(nameservers, results, verbose: options[:verbose])
  end

  desc 'record -r RECORD 8.8.8.8 8.8.4.4', 'Resolve record to ip'
  method_option :record, required: true, aliases: '-r', desc: 'Resolve this record'
  method_option :type, default: 'A', aliases: '-t', desc: 'Record type'
  def record(*nameservers)
    @resolver = Resolver.new(nameservers)
    results = @resolver.resolve(options[:record], options[:type])

    Printer.print(nameservers, [results], verbose: options[:verbose])
  end
end

CLI.start(ARGV)
