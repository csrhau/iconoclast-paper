TEX_FILES = Rake::FileList.new("**/*.tex")

namespace :latex do
  desc "Compile Latex Paper"
  file 'paper.pdf' => TEX_FILES do |pdf|
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
  end

  namespace :pgfplots do


  end
end

namespace :admin do
  desc 'delete one type of file'
  task :fileclean, [:filetype] do |t, args|
    Dir["**/*.#{args.filetype}"].each do |f|
      File.unlink(f)
    end
  end
end

task :default => ["paper.pdf"]
