# Expose all rake tasks in vault-tools
#
# include in Rakefile via:
#
# require 'vault-tools/tasks'
require 'vault-tools/core_db_tasks'
require 'vault-tools/vault_db_tasks'
require 'vault-tools/usage_db_tasks'
require 'vault-tools/analytics_db_tasks'
require 'vault-tools/doc_tasks'

desc "Run all pull schema tasks (all tasks that match pull_.*_schema)"
task :pull_schemas do
  Rake::Task.tasks.select { |task| task.name =~ /pull_.*_schema/ }.each do |task|
    puts "Invoking #{task.name}..."
    task.invoke
  end
end

desc "Run the database migrations against DATABASE_URL"
task :migrate do
  sh 'bundle exec sequel -E -m db/migrations $DATABASE_URL'
end
