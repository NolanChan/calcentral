class PhotoController < ApplicationController
  
  before_action :authenticate
  

  def my_photo
    if session[:user_id]
      photo_row = CampusOracle::Queries.get_photo(session[:user_id])
      if (photo_row)
        data = photo_row['photo']
        send_data(
            data,
            type: 'image/jpeg',
            disposition: 'inline'
        )
      else 
        send_file(
            File.join(Rails.root, 'app/assets/images', 'photo_unavailable_official_72x96.jpg'),
            type: 'image/jpeg',
            disposition: 'inline'
        )
      end
    else
      render :nothing => true, :status => 401
    end
  end

end
