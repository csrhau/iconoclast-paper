require 'optparse'
require 'ostruct'

Mandatory = %i[base_power code_power code_time delay_exp energy_exp roof_power]
Optional =%i[latex]
PoseOptions = Struct.new(*(Mandatory + Optional))

class Parser
  def self.parse(args) 
    options = PoseOptions.new
    # Set any defaults here
    OptionParser.new do |opts|
      opts.banner = "Usage: pose_calculations.rb [options]"
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
      opts.on('--latex', 'Print latex output') do |l|
        options.latex = l 
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

def humanize(i)
  case i
  when 0
    'zero'
  when 1
    'one'
  when 2
    'two'
  when 3
    'three'
  else
    'lots'
  end
end

    
#Let's Do It!
options = Parser.parse(ARGV)

#Optimization intercept with baseline (bottom right most point)
obi = opt_intercept(options.code_power, options.code_time, options.base_power,
                   options.energy_exp, options.delay_exp)
# Optimization intercept with roofline (top right most intersept)
ori = opt_intercept(options.code_power, options.code_time, options.roof_power,
                    options.energy_exp, options.delay_exp)
# Contribution intercept with baseline
cbi = con_intercept(options.code_power, options.code_time, options.base_power,
                    options.energy_exp, options.delay_exp)
# Optimization Limit intercept with roofline (shares baseline intercept with contribution)
lri = opt_intercept(options.base_power, cbi, options.roof_power,
                    options.energy_exp, options.delay_exp)

if options.latex
  puts "\\pgfmathsetmacro{\\codetime}{#{options.code_time}}"
  puts "\\pgfmathsetmacro{\\codepower}{#{options.code_power}}"
  puts "\\pgfmathsetmacro{\\energyexponent}{#{options.energy_exp}}"
  puts "\\pgfmathsetmacro{\\delayexponent}{#{options.delay_exp}}"
  puts "\\pgfmathsetmacro{\\obie}{#{obi}}"
  puts "\\pgfmathsetmacro{\\cbie}{#{cbi}}"
  puts "\\pgfmathsetmacro{\\orie}{#{ori}}"
  puts "\\pgfmathsetmacro{\\lrie}{#{lri}}"
else
  puts "Baseline/Optimization Bound Intercept: #{obi}"
  puts "Baseline/Contribution Bound Intercept: #{cbi}"
  puts "Roofline/Optimization Bound Intercept: #{ori}"
  puts "Roofline/Optimization Limit Intercept: #{lri}"
end
