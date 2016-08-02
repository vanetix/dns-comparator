require 'colorize'
require 'terminal-table'

class Printer
  class << self
    def header(nameservers)
      ['Record', *nameservers]
    end

    def print(nameservers, results, verbose: false)
      table = Terminal::Table.new(
        headings: header(nameservers),
        rows: format_results(results, verbose: verbose)
      )

      puts table
    end

    # Results in format [ [record,  [host, host], [host, host]] ]
    def format_results(results, verbose: false)
      results.map do |result|
        row = []
        cols = result[1..-1]
        size = cols.size

        if verbose
          row.concat(cols.map { |r| r.join(', ') })
        end

        if cols.all? { |r| r.size == 0 }
          row.unshift("#{result.first}".cyan)
          size.times { row << '-'.cyan } unless verbose
        elsif valid(cols)
          row.unshift("#{result.first}".green)
          size.times { row << '✓'.green } unless verbose
        else
          row.unshift("#{result.first}".red)
          size.times { row << 'x'.red } unless verbose
        end

        row
      end
    end

    def valid(result)
      l = result.first.size
      prev = result.first

      result[1..-1].all? do |r|
        l == r.size && prev.all? { |p| r.include?(p) }
      end
    end
  end
end

