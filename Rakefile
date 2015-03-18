TEX_FILES = Rake::FileList.new("**/*.tex").exclude('tab/tex/*.tex')
# Remember to include all generated files in this list (as well as in tasks)
GEN_FILES = ['tab/tex/power_of_cores_x_freq.tex', 'tab/tex/code_metrics.tex']

namespace :latex do
  desc "Compile Latex Paper"
  file 'paper.pdf' => TEX_FILES + GEN_FILES do |tex|
    system("pdflatex paper.tex")
    system("bibtex paper.aux")
    system("pdflatex paper.tex")
    system("pdflatex paper.tex")
  end
  desc 'remove latex build cruft'
  task :tidy do 
    ['aux', 'log', 'blg', 'bbl', 'synctex.gz'].each do |ftype|
      Rake::Task['admin:fileclean'].invoke(ftype)
      Rake::Task['admin:fileclean'].reenable
    end
  end

  desc 'remove all build artefacts'
  task :clean => [:tidy, 'admin:genclean'] do
    Rake::Task["admin:fileclean"].invoke('pdf')
    Rake::Task["admin:fileclean"].reenable
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

namespace :admin do
  desc 'delete one type of file globally'
  task :fileclean, [:filetype] do |t, args|
    Dir["**/*.#{args.filetype}"].each do |f|
      File.unlink(f)
    end
  end

  desc 'delete auto-generated tex files'
  task :genclean do
    Dir['tab/tex/**.tex'].each do |f|
      File.unlink(f)
    end
  end
end

task :default => ["paper.pdf"]
