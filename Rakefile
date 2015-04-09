require 'rake/clean'

TEX_FILES = Rake::FileList.new("**/*.tex").exclude('tab/tex/*.tex')
# Remember to include all generated files in this list (as well as in tasks)
GEN_FILES = ['tab/tex/power_of_cores_x_freq.tex', 'tab/tex/code_metrics.tex']


CLEAN.include (%w[aux log blg bbl synctex.gz].map { |f| "**/*.#{f}" } )
CLOBBER.include GEN_FILES + ['paper.pdf']

namespace :latex do
  desc "Compile Latex Paper"
  file 'paper.pdf' => TEX_FILES + GEN_FILES do |tex|
    system("pdflatex paper.tex")
    system("bibtex paper.aux")
    system("pdflatex paper.tex")
    system("pdflatex paper.tex")
  end

  namespace :tables do
    desc 'Builds a table of power vs core count and cpu frequency' 
    file 'tab/tex/power_of_cores_x_freq.tex' => ['tab/data/power_of_cores_x_freq.csv',
                                                 'tab/tmpl/power_of_cores_x_freq.erb'] do |t|
      ruby "./tab/ruler.rb -d#{t.prerequisites[0]} -t#{t.prerequisites[1]} -o#{t.name}"
    end

    desc 'Builds a table of power metrics for various codes'
    file 'tab/tex/code_metrics.tex' => ['tab/data/code_metrics.csv',
                                        'tab/tmpl/generic.erb']  do |t|
      ruby "./tab/ruler.rb -d#{t.prerequisites[0]} -t#{t.prerequisites[1]} -o#{t.name}"
    end
  end
end

task :default => ["paper.pdf"]
