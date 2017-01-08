class BgUploadController < ApplicationController
  def new

  end

  def create
    nameArr = params[:upload][:file].original_filename.split(/\.(?=[^.]*$)/)
    
    name = nameArr[0] + Time.now.to_i.to_s + '.' + nameArr.last
    directory = "public/body-img"
    if !File.directory?(directory)
      Dir.mkdir directory
    end
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params[:upload][:file].read) }
    flash[:notice] = "File uploaded"
    redirect_to "/bg_uploads/new"
  end
end
