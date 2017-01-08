require 'open-uri'
require 'rexml/document'
require 'csv'
require 'google/api_client'
require 'json'

class DataController < ApplicationController
  @@tableId = '1AREaXlN0hWtHoj7sS8QI8N-cSIT7V4nwlODziC8q'
  @@pkcs12key = Rails.root.join('config', 'rs.p12')
  @@client_email = '559100036996-rujfse4hpbrlnm0t66264shdb42se813@developer.gserviceaccount.com'

  def form
    render :json => {} unless current_user.role?(:admin)
    res = redis.get('layers:api:maps') ||
        begin
          maps = open('http://api.butlermaps.com/riding-social/2.0/svc.php?cmd=searchmaps') { |f| f.read }
          redis.set('layers:api:maps', maps, ex: 60*10)
          maps
        end
    data = JSON.parse(res)
    @maps = data['maps']
  end

  def build
    render :json => {} unless current_user.role?(:admin)
    if params[:ids].blank?
      redirect_to action: 'form'
      return
    end

    ids = params[:ids].map { |x| x.to_i }
    do_clear if params[:clear_old] == '1'

    @imported_maps = []
    jobs = ids.map do |map_id|
      job_id = LayerImporter.perform_async(map_id)
      {map: map_id, job: job_id}
    end

    render :json => jobs
  end

  def jobs
    jobs = params[:jobs].map do |k, task|
      {map: task['map'], job: task['job'], status: Sidekiq::Status::status(task['job'])}
    end
    render :json => jobs
  end

  private

  def do_clear
    logger.info "LayerImport.clear_fusion_table"
    LayerImport.clear_fusion_table
  end

end