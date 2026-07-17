# Maintain Rails < 7 behaviour of installing JavaScript dependencies before
# assets:precompile.
namespace :npm do
  task :install do
    system("npm ci") || raise("npm ci failed")
  end
end

Rake::Task["assets:precompile"].enhance ["npm:install"]
