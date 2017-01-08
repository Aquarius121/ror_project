desc 'PG Backup'
namespace :pg do
  task :backup => [:environment] do
    datestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    backup_file = "~/db_backups/pg_dumpall_#{datestamp}_dump.sql.gz"
    sh "pg_dumpall -h localhost -U pguser | gzip -c > #{backup_file}"
    sh "scp #{backup_file} deploy@46.22.223.59:/home/deploy/backups/prod_postgres_bkp"
  end
end