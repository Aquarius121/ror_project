desc 'extract encoded path from the static map url'
task :fix_static_map => :environment do
  Route.where(['encoded_path like ?', '%[object%']).each do |route|
    STDOUT.puts route.id
    STDOUT.puts route.encoded_path
    route.encoded_path = nil
    route.generate_encoded_path
    STDOUT.puts route.encoded_path
    STDIN.gets
    begin
      route.update_column(:encoded_path, route.encoded_path)
    rescue => e
      STDOUT.puts e
    end
  end
end