class Image < ActiveRecord::Base
  belongs_to :gallery
  
  # http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}.jpg
  # or
  # http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
  # or
  # http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
  #
  # Size Suffixes
  # The letter suffixes are as follows:
  # s small square 75x75
  # t thumbnail, 100 on longest side
  # m small, 240 on longest side
  # - medium, 500 on longest side
  # z medium 640, 640 on longest side
  # b large, 1024 on longest side*
  # o original image, either a jpg, gif or png, depending on source format
  def url(size=:original)
    sizes = {
      :small75 => 's',
      :thumbnail => 't',
      :small240 => 'm',
      :medium500 => '?',
      :medium640 => 'z',
      :large => 'b'
    }
    case size
    when :original
      return "http://farm" + self['flickrFarm'] + ".static.flickr.com/" + self['flickrServer'] + "/" + self['flickrPhotoId'] + "_" + self['flickrSecret'] + ".jpg"
    when :small75, :thumbnail, :small240, :medium500, :medium640, :large
      return "http://farm" + self['flickrFarm'] + ".static.flickr.com/" + self['flickrServer'] + "/" + self['flickrPhotoId'] + "_" + self['flickrSecret'] + "_" + sizes[size] + ".jpg"
    else
      error "invalid size: " + size.to_s
    end
  end

  def linkbackUrl() 
    'http://www.flickr.com/photos/' + self['flickrOwnerId'].to_s + '/' + self['flickrPhotoId'].to_s
  end
  
end
