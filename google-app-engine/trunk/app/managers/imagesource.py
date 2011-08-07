import gaeflickrlib
import logging
import pprint

logger = logging.getLogger('FlickrImageSource')

sorts = {
         'date-posted-asc' : 'date-posted-asc',
         'date-posted-desc' : 'date-posted-desc',
         'date-taken-asc' : 'date-taken-asc',
         'date-taken-desc' : 'date-taken-desc',
         'interestingness-desc' : 'interestingness-desc',
         'interestingness-asc' : 'interestingness-asc',
         'relevance' : 'relevance'
         }

class FlickrImageSource:
    api_key = None

    def __init__(self, api_key):
        self.api_key = api_key

    # Returns a list of maps from flickr for a search term
    # map contains photo info key
    def getPhotos(self, searchTerm):
        resultSet = FlickrPhotoSet(searchTerm)
        flickr = gaeflickrlib.GaeFlickrLib(api_key = self.api_key)
        photoset = flickr.photos_search(text='"' + searchTerm + '" ' + searchTerm,
                                        sort=sorts['relevance'],
                                        content_type=1, # photos only
                                        media='photos',
                                        license='Attribution,Attribution-NoDerivs,Attribution-ShareAlike',
                                        extras='description,owner_name,o_dims',
                                        per_page=20)
        # o_dims gives us the original file size: o_width, o_height
        logger.info("Found " + str(len(photoset.photos)) + " photos for search term " + searchTerm)
        if(len(photoset.photos) < 10):
            # If there's less than 10 images, we're not going to use this gallery anyways, so don't bother
            return resultSet
        
        for flickrPhoto in photoset.photos:
            photo = FlickrPhoto()
            photo.id = flickrPhoto['id']
            photo.title = flickrPhoto['title']
            photo.ownerId = flickrPhoto['owner']
            photo.farm = flickrPhoto['farm']
            photo.server = flickrPhoto['server']
            photo.secret = flickrPhoto['secret']
            photo.description = flickrPhoto['description']
            photo.ownerDisplayName = flickrPhoto['ownername']
            photo.height = flickrPhoto['o_height'] if 'o_height' in flickrPhoto else None
            photo.width= flickrPhoto['o_width'] if 'o_width' in flickrPhoto else None
            if photo.height and photo.width:
                photo.aspect_ratio = float(photo.width) / float(photo.height)
            else:
                photo.aspect_ratio = None
            resultSet.addPhoto(photo)
        # logger.info("PHOTOS: " + pprint.PrettyPrinter(indent=4).pformat([photo.__dict__ for photo in resultSet.photos]))
        return resultSet

class FlickrPhoto:
    def __init__(self):
        pass
    
    def __str__(self):
        return "[FlickrPhoto (id=" + self.id + ")(title=" + self.title + ")(ownerId=" + self.ownerId + ")(ownerDisplayName=" + self.ownerDisplayName + ")(farm=" + self.farm + ")(server=" + self.server + ")(secret=" + self.secret + ")(description=" + self.description + ")]"
    
class FlickrPhotoSet:
    def __init__(self, searchTerm):
        self.searchTerm = searchTerm
        self.photos = []
        pass

    def addPhoto(self, flickrPhoto):
        self.photos.append(flickrPhoto)
    
    def getSamplePhoto(self):
        for photo in self.photos:
            if photo.aspect_ratio != None:
                return photo
        return self.photos[0]
    


