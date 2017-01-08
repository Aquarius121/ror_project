module ClubsHelper

  def club_logo_url(club, size = :thumb)
    if !club.logo_id?
      asset_path('club-default-img.png')
    else
      Attachment.find(club.logo_id).file.url(size)
    end
  end
end
