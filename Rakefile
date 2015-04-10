require 'rake/clean'

TEX_FILES = Rake::FileList.new('**/*.tex')
TAB_FILES = Rake::FileList.new('tab/data/*.csv').map do |f|
  f.sub(%r{^tab/data}, 'tab/tex').sub(%r{\.csv$}, '.tex')
end

CLEAN.include %w[aux log blg bbl synctex.gz].map { |f| "**/*.#{f}" }
CLOBBER.include %w[paper.pdf tab/tex]

namespace :latex do
  desc "Compile Latex Paper"
  file 'paper.pdf' => TEX_FILES + TAB_FILES do |tex|
    system("pdflatex paper.tex")
    system("bibtex paper.aux")
    system("pdflatex paper.tex")
    system("pdflatex paper.tex")
  end
end

namespace :tables do
  desc 'creates an output directory for latex tables'
  directory 'tab/tex'

  #General rule for constructing tables
  rule(%r{^tab/tex/.*\.tex$} => [lambda { |fn| fn.sub(/tab\/tex/, 'tab/data').sub(/\.tex$/, '.csv')},
                                 lambda { |fn| fn.sub(/tab\/tex/, 'tab/tmpl').sub(/\.tex$/, '.erb')},
                                 'tab/tex']) do |t|
    ruby "./tab/ruler.rb -d#{t.prerequisites[0]} -t#{t.prerequisites[1]} -o#{t.name}"
  end
end

task :default => ["paper.pdf"]
