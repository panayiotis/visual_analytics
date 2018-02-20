namespace :livy_daemon do
  desc 'TODO'
  task start: :environment do
    puts 'Start Livy Daemon job'
    LivyDaemonJob.perform_now
  end
end
