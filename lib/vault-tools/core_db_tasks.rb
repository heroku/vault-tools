# Rake tasks for Core DB
#
# include in Rakefile via:
#
# require 'vault-tools/core_db_tasks'

desc "Pull db/structure.sql from core HEAD"
task :pull_core do
  steps = []
  steps << 'cd contrib/'
  if File.exists?('contrib/core')
    steps << 'rm -rf core'
  end
  steps << 'git clone -n git@github.com:heroku/core --depth 1'
  steps << 'cd core'
  steps << 'git checkout HEAD db/structure.sql'
  sh steps.join(' && ')
end

desc "Drop and create vault-usage-test, core-test and shushu-test databases"
task :create_core_db => [:drop_core_db, :pull_core] do
  sh 'createdb core-test'
  sh 'psql core-test -f contrib/core/db/structure.sql'
end

desc "Drop the vault-usage-test, core-test and shushu-test databases"
task :drop_core_db do
  sh 'dropdb core-test || true'
end
