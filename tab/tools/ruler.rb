# This program takes a csv datafile and an erb template and combines them.
# The use case for this simple script is to produce latex tables from csv.
#
require 'csv'
require 'erb'
require 'optparse'

Options = Struct.new(:datafile, :templatefile, :outfile)
class Parser
  def self.parse(args)
    options = Options.new
    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: ruby ruler.rb [args]'
      opts.on('-dFILE', '--data=FILE', 'Data Filename') { |f|  options.datafile = f }
      opts.on('-tFILE', '--template=FILE', 'Template Filename') { |f|  options.templatefile = f }
      opts.on('-oFILE', '--output=FILE', 'Output Filename') { |f| options.outfile = f }
      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end
    end
    opt_parser.parse!(args)
    raise OptionParser::MissingArgument if options.datafile.nil?
    raise OptionParser::MissingArgument if options.templatefile.nil?
    return options
  end
end

def process(args)
  options = Parser.parse args.empty? ? %w[--help] : args
  data = CSV.read(options.datafile, headers:true)
  template = ERB.new(File.new(options.templatefile).read, nil, '-')
  output = template.result(binding)
  if options.outfile.nil?
    puts output
  else
    File.write(options.outfile, output)
  end
end

process ARGV

