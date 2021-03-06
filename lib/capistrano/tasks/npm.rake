desc "Install needed node packages"
task :npm_install, [] => [] do |t, args|
  on roles(:web, :job, :app, :cron) do
    within release_path do
      execute :npm, :install
    end
  end
end
