# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'mnl24'
set :repo_url, 'git@github.com:sulvz/mnl24.git'

set :deploy_to, '/home/deploy/mnl24'

set :linked_files, %w{config/database.yml config/secrets.yml .env}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Runs rake db:migrate'
  task :migrate => [:set_rails_env] do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:migrate'
        end
      end
    end
  end

  after :updated,  'deploy:migrate'
  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'

end
