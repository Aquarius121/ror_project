class BgViewHelper

  @@images = File.directory?("public/body-img") ? Dir.glob("**/public/body-img/*").map{|i| i.split('/').last} : []
  #%w(1DSC_00771393231860.jpg 1DSC_02711393231930.JPG 1DSC_02751393232052.jpg bg-21387797304.jpg)
  @@images_size = @@images.size
  @@controllers = %w(sessions registrations passwords)
  @@actions = %w(new create invite inviterequest frominvite edit combined)

  def self.body_bg_class(controller)
    if @@controllers.include?(controller.controller_name) &&
        @@actions.include?(controller.action_name)
      'with-bg'
    end
  end

  def self.randomized_background_image
    "/body-img/" + @@images[rand(@@images_size)]
  end

end