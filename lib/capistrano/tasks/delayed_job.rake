# Do not use capistrano-delayed job gem as it's not needed.

namespace :delayed_job do
  task :restart do
    on roles(:job) do
      sudo "bash -l -c '/usr/bin/systemctl stop delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.1.service || echo ok'"
    end
    on roles(:job) do
      sudo "/usr/bin/systemctl start delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.1.service"
    end
    on roles(:job) do
      sudo "bash -l -c '/usr/bin/systemctl stop delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.2.service || echo ok'"
    end
    on roles(:job) do
      sudo "/usr/bin/systemctl start delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.2.service"
    end
    on roles(:job) do
      sudo "bash -l -c '/usr/bin/systemctl stop delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.3.service || echo ok'"
    end
    on roles(:job) do
      sudo "/usr/bin/systemctl start delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.3.service"
    end
  end

  task :stop do
    on roles(:job) do
      sudo "/usr/bin/systemctl stop delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.1.service"
      sudo "/usr/bin/systemctl stop delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.2.service"
      sudo "/usr/bin/systemctl stop delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.3.service"
    end
  end

  task :start do
    on roles(:job) do
      sudo "/usr/bin/systemctl start delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.1.service"
      sudo "/usr/bin/systemctl start delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.2.service"
      sudo "/usr/bin/systemctl start delayed_job-#{fetch(:client)}-hmis-#{fetch(:rails_env)}.3.service"
    end
  end
end
