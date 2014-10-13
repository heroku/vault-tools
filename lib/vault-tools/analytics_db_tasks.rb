# Rake tasks for Analytics DB
#
# include in Rakefile via:
#
# require 'vault-tools/analytics_db_tasks'

desc "Pull db/vault-analytics.sql from api HEAD"
task :pull_analytics_schema do
  steps = []
  steps << 'mkdir -p contrib/'
  steps << 'cd contrib/'
  if File.exists?('contrib/vault-analytics')
    steps << 'rm -rf vault-analytics'
  end
  steps << 'git clone -n git@github.com:heroku/vault-analytics --depth 1'
  steps << 'cd vault-analytics'
  steps << 'git checkout HEAD db/vault-analytics.sql'
  # make sure we don't submodule it
  steps << 'rm -rf .git'
  sh steps.join(' && ')
end

desc "Drop and recreate the vault-analytics-test database"
task :create_analytics_db => [:drop_analytics_db] do
  sh 'createdb vault-analytics-test'
  sh 'psql --no-psqlrc vault-analytics-test -f contrib/vault-analytics/db/vault-analytics.sql'
end

desc "Drop the vault-analytics-test database"
task :drop_analytics_db do
  sh 'dropdb vault-analytics-test || true'
end
