desc 'Notify users about card operation via email'
task :cc_operation => :environment do
  operations = CardTransaction.waiting
  STDOUT.puts "Operations to process: #{operations.count}"
  operations.each do |operation|
    CCOperationNotificator.perform_async(operation.id)
  end
end