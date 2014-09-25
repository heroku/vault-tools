# Rake tasks for Usage DB
#
# include in Rakefile via:
#
# require 'vault-tools/usage_db_tasks'

desc "Pull db/vault-usage.sql from api HEAD"
task :pull_usage_schema do
  steps = []
  steps << 'mkdir -p contrib/'
  steps << 'cd contrib/'
  if File.exists?('contrib/vault-usage')
    steps << 'rm -rf vault-usage'
  end
  steps << 'git clone -n git@github.com:heroku/vault-usage --depth 1'
  steps << 'cd vault-usage'
  steps << 'git checkout HEAD db/vault-usage.sql'
  steps << 'git checkout HEAD db/functions.sql'
  # make sure we don't submodule it
  steps << 'rm -rf .git'
  sh steps.join(' && ')
end

desc "Drop and recreate the vault-usage-test database"
task :create_usage_db => [:drop_usage_db] do
  sh 'createdb vault-usage-test'
  sh 'psql vault-usage-test -f contrib/vault-usage/db/vault-usage.sql'
  sh 'psql vault-usage-test -f contrib/vault-usage/db/functions.sql'
end

desc "Drop the vault-usage-test database"
task :drop_usage_db do
  sh 'dropdb vault-usage-test || true'
end
