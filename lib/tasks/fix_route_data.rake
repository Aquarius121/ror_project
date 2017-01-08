desc 'fix route data format'
task :fix_route_data => :environment do
  Route.where(['data like ?', '%route_data":[["%']).each do |route|
    STDOUT.puts route.id
    data = ActiveSupport::JSON.decode(route.data)
    data['route_data'] = data['route_data'].map{|p| p.map{|l| l.to_f} }
    STDOUT.puts ActiveSupport::JSON.encode data
    STDIN.gets
    route.data = ActiveSupport::JSON.encode data
    route.save
  end
end