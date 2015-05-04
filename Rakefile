require 'rake/clean'

CLEAN.include %w[aux log blg bbl out nav toc vrb snm synctex.gz].map { |f| "**/*.#{f}" }
CLOBBER.include %w[./paper.pdf ./group_presentation.pdf tab/tex plot/**/*.pdf]
PAPER_TEX = Rake::FileList.new('**/*.tex').exclude('group_presentation.tex')
PRES_TEX = Rake::FileList.new('group_presentation.tex')
TABLES = Rake::FileList.new('tab/data/*.csv').map do |f|
  base = File.basename(f, '.csv')
  {:tex => "tab/tex/#{base}.tex",
   :csv => "tab/data/#{base}.csv", 
   :erb => "tab/tmpl/#{base}.erb" }
end

namespace :latex do
  desc "Compile Latex Paper"
  file 'paper.pdf' => PAPER_TEX + TABLES.map { |t| t[:tex] } do |tex|
    system("pdflatex paper.tex")
    system("bibtex paper.aux")
    system("pdflatex paper.tex")
    system("pdflatex paper.tex")
  end

  desc 'Do a single pdflatex pass for paper'
  task 'single' => PAPER_TEX + TABLES.map { |t| t[:tex] } do |tex|
    system("pdflatex paper.tex")
  end

  desc 'Compile group presentation'
  file 'group_presentation.pdf' => PRES_TEX + PAPER_TEX do |tex| #todo HANDLE PLOT updates correctly
    system("pdflatex group_presentation.tex")
  end
end

namespace :tables do
  desc 'creates an output directory for latex tables'
  directory 'tab/tex'
  TABLES.each do |t|
    desc "Build table output file #{t[:tex]}"
    file t[:tex] => ['tab/tools/ruler.rb', t[:csv], t[:erb], 'tab/tex'] do |t|
      ruby "#{t.prerequisites[0]} -d#{t.prerequisites[1]} -t#{t.prerequisites[2]} -o#{t.name}"
    end
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
