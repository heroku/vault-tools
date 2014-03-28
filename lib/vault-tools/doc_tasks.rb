# Documentation Tasks
# 
#
require 'vault-tools/s3'

namespace :docs do
  desc "Publish Docs to S3"
  task :publish do
    DOC_BUCKET = "heroku-vault-docs2"
    DOC_DIR_NAME = Dir.pwd.split("/").last

    # Check for s3cmd CLI
    response = system('s3cmd --version')
    raise "\n\n\033[1;31m Install s3cmd through 'brew install s3cmd' if you are on a Mac or from 'http://s3tools.org/s3cmd' to use this feature.\033[0m\n\n\n" unless response
   
    # Configure your docs amazon creds if you haven't already
    unless File.exist?("#{Dir.home}/.s3cfg_docs")
      puts "Configuring S3 Doc Creds - make sure you answer 'y' when asked to save ..."
      sh 's3cmd --configure --config ~/.s3cfg_docs'
    end

    # Build Docs
    Rake::Task["yard"].invoke
     
    # Copy
    sh 'mkdir -p ~/tmp'
    sh "cp -R doc ~/tmp/#{DOC_DIR_NAME}"
    
    system  "s3cmd mb s3://#{DOC_BUCKET} --config ~/.s3cfg_docs"
    res = system("s3cmd -P put -r ~/tmp/#{DOC_DIR_NAME} s3://#{DOC_BUCKET}/ --config ~/.s3cfg_docs")
    
    unless res
      puts "\n\033[1;31m Make sure you put the doc credentials in .s3cfg_docs file. If you don't have them talk to the S3 doc administrator.\033[0m\n\n"
      exit
    end
    
    # Cleanup
    sh "rm -r ~/tmp/#{DOC_DIR_NAME}"
    
    # Restart Vault Docs
    puts "\n \033[1;32m Make sure to restart the vault-docs app to see NEW docs! \033[0m\n"
  end
end
