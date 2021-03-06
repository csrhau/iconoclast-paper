require 'optparse'
require 'ostruct'

Mandatory = %i[base_power code_power code_time delay_exp energy_exp roof_power]
Optional =%i[format]
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
      opts.on('--roof-power RP', Float, 'System Roofline Power (W)') do |rp|
        options.roof_power = rp
      end
      #P_{\theta}
      opts.on('--code-power CP', Float, 'Unoptimised Code Power (W)') do |cp|
        options.code_power = cp
      end
      #D_{\theta}
      opts.on('--code-time T', Float, 'Unoptimised Code Runtime (s)') do |ct|
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

      # Optional argument with keyword completion.
      opts.on("--format [FORMAT]", [:text, :latex, :table],
              "OPTIONAL: Select output format (text, latex, table)") do |f|
        options.format=f
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

case options.format
when :latex
  puts "\\pgfmathsetmacro{\\codetime}{#{options.code_time}}"
  puts "\\pgfmathsetmacro{\\codepower}{#{options.code_power}}"
  puts "\\pgfmathsetmacro{\\energyexponent}{#{options.energy_exp}}"
  puts "\\pgfmathsetmacro{\\delayexponent}{#{options.delay_exp}}"
  puts "\\pgfmathsetmacro{\\brnodex}{#{obi}}"
  puts "\\pgfmathsetmacro{\\blnodex}{#{cbi}}"
  puts "\\pgfmathsetmacro{\\trnodex}{#{ori}}"
  puts "\\pgfmathsetmacro{\\tlnodex}{#{lri}}"
when :table
  puts "Axis,$\\theta$,A,B,C,D,E"
  puts "Runtime (S),#{options.code_time},#{lri},#{ori},#{cbi},#{options.code_time},#{obi}"
  puts "Energy (J),#{options.code_time * options.code_power},#{lri * options.roof_power},#{ori * options.roof_power},"\
       "#{cbi * options.base_power},#{options.code_time * options.base_power},"\
       "#{obi * options.base_power}"
else # default (:text)
  puts "$\\theta$ Original Code Measurements: #{options.code_time}s, #{options.code_time * options.code_power}J, #{(options.code_time * options.code_power) ** options.energy_exp * options.code_time ** options.delay_exp} ($\\theta$)"
  puts "A Roofline/Optimization Limit Intercept: #{lri}s, #{lri * options.roof_power}J, #{(lri * options.roof_power) ** options.energy_exp * lri ** options.delay_exp} (A)"
  puts "B Roofline/Optimization Bound Intercept: #{ori}s, #{ori * options.roof_power}J, #{(ori * options.roof_power) ** options.energy_exp * ori ** options.delay_exp} (B)"
  puts "C Baseline/Contribution Bound Intercept: #{cbi}s, #{cbi * options.base_power}J, #{(cbi * options.base_power) ** options.energy_exp * cbi ** options.delay_exp} (C)"
  puts "D Baseline/Vertical Code Time Intercept: #{options.code_time}s, #{options.code_time * options.base_power}J, #{(options.code_time * options.base_power) ** options.energy_exp * options.code_time ** options.delay_exp} (D)"
  puts "E Baseline/Optimization Bound Intercept: #{obi}s, #{obi * options.base_power}J, #{(obi * options.base_power) ** options.energy_exp * obi ** options.delay_exp} (E)"
end
