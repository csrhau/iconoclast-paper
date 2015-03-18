TEX_FILES = Rake::FileList.new("**/*.tex")
GEN_FILES = ['tab/tex/power_of_cores_x_freq.tex']


namespace :latex do
  desc "Compile Latex Paper"
  file 'paper.pdf' => TEX_FILES + GEN_FILES do |tex|
    p tex
    system("pdflatex paper.tex")
    system("bibtex paper.aux")
    system("pdflatex paper.tex")
    system("pdflatex paper.tex")
  end
  desc 'remove latex build cruft'
  task :tidy do 
    ['aux', 'log', 'blg', 'bbl', 'synctex.gz'].each do |ftype|
      Rake::Task["admin:fileclean"].invoke(ftype)
      Rake::Task["admin:fileclean"].reenable
    end
  end

  desc 'remove all build artefacts'
  task :clean => :tidy do
    Rake::Task["admin:fileclean"].invoke('pdf')
    Rake::Task["admin:fileclean"].reenable
    Rake::Task["admin:genclean"].execute
  end

  namespace :tables do
    desc 'Builds a table of power vs core count and cpu frequency' 
    file 'tab/tex/power_of_cores_x_freq.tex' => ['tab/data/power_of_cores_x_freq.csv',
                                                 'tab/tmpl/power_of_cores_x_freq.erb'] do
      ruby './tab/ruler.rb -d./tab/data/power_of_cores_x_freq.csv -t./tab/tmpl/power_of_cores_x_freq.erb -o./tab/tex/power_of_cores_x_freq.tex'
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
