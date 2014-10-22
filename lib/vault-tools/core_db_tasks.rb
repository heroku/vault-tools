# Rake tasks for Core DB
#
# include in Rakefile via:
#
# require 'vault-tools/core_db_tasks'

desc "Pull db/structure.sql from api HEAD"
task :pull_core_schema do
  steps = []
  steps << 'mkdir -p contrib/'
  steps << 'cd contrib/'
  if File.exists?('contrib/core')
    steps << 'rm -rf core'
  end
  steps << 'git clone -n git@github.com:heroku/api core --depth 1'
  steps << 'cd core'
  steps << 'git checkout HEAD db/structure.sql'
  steps << 'git checkout HEAD db/analytics_grants.sql'
  # make sure we don't submodule it
  steps << 'rm -rf .git'
  sh steps.join(' && ')
end

desc "Drop and recreate the core-test database"
task :create_core_db => [:drop_core_db] do
  sh 'createdb core-test'
  sh 'psql --no-psqlrc core-test -c "DROP ROLE IF EXISTS analytics;"'
  sh 'psql --no-psqlrc core-test -c "CREATE ROLE analytics ENCRYPTED PASSWORD \'password\' LOGIN;"'
  sh 'psql --no-psqlrc core-test -f contrib/core/db/structure.sql'
  sh 'psql --no-psqlrc core-test -f contrib/core/db/analytics_grants.sql'
end

desc "Drop the core-test database"
task :drop_core_db do
  sh 'dropdb core-test || true'
end
