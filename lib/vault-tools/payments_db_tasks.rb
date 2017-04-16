# Rake tasks for payments DB
#
# include in Rakefile via:
#
# require 'vault-tools/payments_db_tasks'

desc "Pull db/payments.sql from api HEAD"
task :pull_payments_schema do
  steps = []
  steps << 'mkdir -p contrib/'
  steps << 'cd contrib/'
  if File.exists?('contrib/payments')
    steps << 'rm -rf payments'
  end
  steps << 'git clone -n git@github.com:heroku/payments --depth 1'
  steps << 'cd payments'
  steps << 'git checkout HEAD db/structure.sql'
  # make sure we don't submodule it
  steps << 'rm -rf .git'
  sh steps.join(' && ')
end

desc "Drop and recreate the payments-test database"
task :create_payments_db => [:drop_payments_db] do
  sh 'createdb payments-test'
  sh 'psql payments-test -f contrib/payments/db/structure.sql'
end

desc "Drop the payments-test database"
task :drop_payments_db do
  sh 'dropdb payments-test || true'
end
