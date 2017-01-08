class Webshot
  include Sidekiq::Worker

  def perform(url, path)
    tempfile = path
    cmd = "/usr/local/bin/wkhtmltoimage  --width 940 --height 490 \"#{url}\" \"#{tempfile}\""
    system(cmd) # sometimes returns false even if image was saved
    File.new(tempfile) # will throw if not saved
  end

end