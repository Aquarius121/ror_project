require 'open-uri'
require 'csv'
require 'google/api_client'
require 'json'

class LayerImport

  def work(butler_map_id)
    @map_id = butler_map_id
    url = "http://api.butlermaps.com/riding-social/2.0/export.php?cmd=exportmap&map=#{@map_id}"
    res = open(url) { |f| f.read }
    File.open(Rails.root.join('tmp', 'cache', "map-#{@map_id}.xml"), 'w') { |f| f.write(res) }
    data = self.decode_export(res)
    self.import(data)
  end

  def import(data)
    id = 0
    csv_body = CSV.generate do |csv|
      data.each do |segment|
        id += 1
        csv << [@map_id*100000 + id, @map_id, segment[:type], segment[:subtype], "<LineString><coordinates>#{segment[:points]}</coordinates></LineString>"]
      end
    end
    return Struct.new(:status).new(200) if csv_body == ''
    File.open(Rails.root.join('tmp', 'cache', "map-#{@map_id}.csv"), 'w') { |f| f.write(csv_body) }
    self.import_into_fusion(csv_body)
  end

  def import_into_fusion(body)
    response = google_api.execute(
        api_method: fusion_table_api.table.import_rows,
        parameters: {
            tableId: '1AREaXlN0hWtHoj7sS8QI8N-cSIT7V4nwlODziC8q',
            uploadType: 'media'
        },
        body: body,
        headers: {'Content-Type' => 'application/octet-stream'}
    )

    if response.status != 200
      Rails.logger.info "import_into_fusion response (code <> 200): #{response}"
    end

    if response.status == 503
      Kernel.sleep(2.0)
      return self.import_into_fusion(body)
    end

    response
  end

  def decode_export(xml)
    doc = Nokogiri::XML(xml)
    return doc.css('Placemark').map do |node|
      name = node.at_css('name').text
      style = node.at_css('styleUrl').text
      points = node.at_css('LineString coordinates').text.gsub(/,0\s/, ' ').strip
      {
          type: get_type(name),
          subtype: get_sub_type(style),
          points: points
      }
    end
  end

  def google_api
    @client ||= init_client
  end

  def fusion_table_api
    @ft ||= google_api.discovered_api('fusiontables', 'v1')
  end

  def clear_fusion_table
    response = google_api.execute(
        api_method: fusion_table_api.query.sql,
        parameters: {
            sql: "DELETE FROM 1AREaXlN0hWtHoj7sS8QI8N-cSIT7V4nwlODziC8q"
        }
    )
    if response.status == 503
      Kernel.sleep(2.0)
      return self.clear_fusion_table
    end
    if response.status != 200
      Rails.logger.info "clear_fusion_table response (code <> 200): #{response}"
      return false
    end

    response
  end

  def self.clear_fusion_table
    me = new
    me.clear_fusion_table
  end


  private

  def init_client
    client = Google::APIClient.new(
        :application_name => 'ButlerMaps',
        :application_version => '1.0.0'
    )
    key_filename = Rails.root.join('config', 'rs.p12')
    key = Google::APIClient::KeyUtils.load_from_pkcs12(key_filename, 'notasecret')
    client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/fusiontables',
        :issuer => '559100036996-rujfse4hpbrlnm0t66264shdb42se813@developer.gserviceaccount.com',
        :signing_key => key
    )
    client.authorization.fetch_access_token!
    client
  end

  def get_type(name)
    case name
      when 'G1' then 1
      when 'G2' then 2
      when 'G3' then 3
      else 0
    end
  end

  def get_sub_type(style)
    case style
      when 'lhstyle' then 1
      when 'pmtstyle' then 2
      when 'dirtstyle' then 3
      else 0
    end
  end

end
