require 'rake/clean'

CLEAN.include %w[aux log blg bbl out synctex.gz].map { |f| "**/*.#{f}" }
CLOBBER.include %w[./paper.pdf tab/tex plot/**/*.pdf]
TEX_FILES = Rake::FileList.new('**/*.tex')
TAB_FILES = Rake::FileList.new('tab/data/*.csv').map do |f|
  f.sub(%r{^tab/data}, 'tab/tex').sub(%r{\.csv$}, '.tex')
end

namespace :latex do
  desc "Compile Latex Paper"
  file 'paper.pdf' => TEX_FILES + ['tables:all'] do |tex|
    system("pdflatex paper.tex")
    system("bibtex paper.aux")
    system("pdflatex paper.tex")
    system("pdflatex paper.tex")
  end
end

namespace :tables do
  desc 'creates an output directory for latex tables'
  directory 'tab/tex'

  desc 'builds all table latex files'
  task :all => TAB_FILES

  #General rule for constructing tables
  rule(%r{^tab/tex/.*\.tex$} => [lambda { |fn| fn.sub(/tab\/tex/, 'tab/data').sub(/\.tex$/, '.csv')},
                                 lambda { |fn| fn.sub(/tab\/tex/, 'tab/tmpl').sub(/\.tex$/, '.erb')},
                                 'tab/tex']) do |t|
    ruby "./tab/tools/ruler.rb -d#{t.prerequisites[0]} -t#{t.prerequisites[1]} -o#{t.name}"
  end
end

namespace :standalone do
  PLOT_FILES = Rake::FileList.new('plot/**/plot.tex').map { |fn| fn.sub(/\.tex$/, '.pdf') }

  desc 'builds all plots in standalone format (for development)'
  task :plots => PLOT_FILES

  rule(%r{plot/.*/plot\.pdf} => [lambda { |fn| fn.sub(/plot\.pdf$/, 'plot_core.tex') },
                                 lambda { |fn| fn.sub(/\.pdf$/, '.tex') }]) do |t|
    Dir.chdir((File.dirname(t.prerequisites.first))) do
      system('pdflatex plot.tex')
    end
  end
end

task :default => ["paper.pdf"]
