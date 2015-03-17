require 'optparse'

Options = Struct.new(:file)
class Parser
  def self.parse(args)
    options = Options.new()
    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: ruby ruler.rb [options]'
      opts.on('-fFILE', '--file=FILE', 'Input Filename') { |f| options.file = f }
      opts.on('-h', '--help', 'Output this message') do
        puts opts
        exit 1
      end
    end.parse(args)
    return options
  end
end
