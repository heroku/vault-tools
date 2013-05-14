# Rake tasks for Shushu DB
#
# include in Rakefile via:
#
# require 'vault-tools/shushu_db_tasks'

desc "Pull db/structure.sql from shushu HEAD"
task :pull_shushu do
  steps = []
  steps << 'cd contrib/'
  if File.exists?('contrib/shushu')
    steps << 'rm -rf shushu'
  end
  steps << 'git clone -n git@github.com:heroku/shushud shushu --depth 1'
  steps << 'cd shushu'
  steps << 'git checkout HEAD db/*'
  # make sure we don't submodule it
  steps << 'rm -rf .git'
  sh steps.join(' && ')
end

desc "Drop and create shushu-test database"
task :create_shushu_db => [:drop_shushu_db, :pull_shushu] do
  sh 'createdb shushu-test'
  sh 'cd contrib/shushu && ../../vendor/bin/sequel postgres:///shushu-test -m db/migrations'
end

desc "Drop the vault-usage-test, core-test and shushu-test databases"
task :drop_shushu_db do
  sh 'dropdb shushu-test || true'
end