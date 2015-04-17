require 'optparse'
require 'ostruct'

Mandatory = %i[base_power code_power code_time delay_exp energy_exp]
Optional =%i[roof_power]
ProseOptions = Struct.new(*(Mandatory + Optional))

class Parser
  def self.parse(args) 
    options = ProseOptions.new
    # Set any defaults here
    OptionParser.new do |opts|
      opts.banner = "Usage: prose_calculations.rb [options]"
      #P_{\alpha}
      opts.on('--base-power BP', Float, 'System Baseline Power (W)') do |bp|
        options.base_power = bp 
      end
      #P_{\beta}
      opts.on('--roof-power RP', Float, 'System Roofline Power (W) [Optional]') do |rp|
        options.roof_power = rp
      end
      #P_{\theta}
      opts.on('--code-power CP', Float, 'Unoptimized Code Power (W)') do |cp|
        options.code_power = cp
      end
      #D_{\theta}
      opts.on('--code-time T', Float, 'Unoptimized Code Runtime (S)') do |ct|
        options.code_time = ct
      end
      #E^m m value
      opts.on('--energy-exponent M', Float, 'Energy Exponent') do |m|
        options.energy_exp = m
      end
      #D^n n value. 
      opts.on('--delay-exponent N', Float, 'Delay Exponent') do |n|
        options.delay_exp = n
      end
      # Print help message
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!(args.empty? ? %w[--help] : args)
    raise OptionParser::MissingArgument unless Mandatory.none? { |o| options[o].nil? }  
    options
  end
end 

# The Envelope - Optimization bound intercepts (top / right) 
def opt_intercept(pt, dt, pb, m, n)
  et = pt * dt
  ((et**m * dt**n) / pb) ** (1 / (m * (n + 1)))
end

# The Envelope - Contribution bound intercept (left)
def con_intercept(pt, dt, pb, m, n)
  ((dt ** (m + n) * pb ** m) / pt**m) ** (1 / (n + 1))
end

#Let's Do It!
options = Parser.parse(ARGV)
p options

ri = opt_intercept(options.code_power, options.code_time, options.base_power,
                   options.energy_exp, options.delay_exp)
puts "Baseline/Optimization Bound Intercept: #{ri}"
li = con_intercept(options.code_power, options.code_time, options.base_power,
                    options.energy_exp, options.delay_exp)
puts "Baseline/Contribution Bound Intercept: #{li}"
if options.roof_power
  ti = opt_intercept(options.code_power, options.code_time, options.roof_power,
                     options.energy_exp, options.delay_exp)
puts "Roofline/Optimization Bound Intercept: #{ti}"
end
puts "pgfplots text: domain=%.7g:%.7g" % [li, ri]

