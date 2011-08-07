import logging
import pprint
import datetime
import re

from google.appengine.ext import db
from google.appengine.ext import webapp

from app.managers.imagesource import FlickrImageSource
from app.models.gallery import Gallery
from app.models.gallery import GalleryManager
from app.models.gallery import starts_with
from app.models.photo import Photo

logger = logging.getLogger('IngestGalleryPage')
pprinter = pprint.PrettyPrinter(indent=4)

# Replace anything that isn't a valid GAE task name char with _
# Ok, thought we'd need this.. leaving it here for now
def topic_task_name(topic):
    return re.sub('[^0-9a-zA-Z\-\_]','_',topic)
    
class IngestGalleryPage(webapp.RequestHandler): 
    def __init__(self):
        self.galleryManager = GalleryManager()

    def post(self):
        topic = self.request.get('topic')
        if(topic == None or topic == ''):
            raise "No topic provided"
        
        source = FlickrImageSource(api_key = "1cbf08d9a5065e7c1496afff9fa4b896")
        photo_set = source.getPhotos(topic)
        start = datetime.datetime.now()
        logger.info('Running ingestion for topic "' + topic + '" at ' + start.isoformat(' '))
        if len(photo_set.photos) == 0:
            logger.info("No photos found for term: " + photo_set.searchTerm)
            self.response.out.write("No photos found for term: " + photo_set.searchTerm)
            return
        
        logger.info("Creating/Updating gallery for term: " + photo_set.searchTerm + " with " + str(len(photo_set.photos)) + " photos")
        fPhoto = photo_set.getSamplePhoto()
        tempPhoto = Photo(flickrPhotoId = fPhoto.id,
                          title = (fPhoto.title if (fPhoto.title != None and fPhoto.title != "") else "Untitled"),
                          description = fPhoto.description,
                          aspect_ratio = fPhoto.aspect_ratio,
                          flickrOwnerId = fPhoto.ownerId,
                          flickrOwnerDisplayName = fPhoto.ownerDisplayName,
                          flickrFarm = fPhoto.farm,
                          flickrServer = fPhoto.server,
                          flickrSecret = fPhoto.secret)
        gallery = Gallery.get_or_insert(photo_set.searchTerm, 
                                        search_term = photo_set.searchTerm,
                                        starts_with = starts_with(photo_set.searchTerm),
                                        sample_photo_url = tempPhoto.getUrl('original'))
        gallery.starts_with = starts_with(photo_set.searchTerm)
        gallery.sample_photo_url = tempPhoto.getUrl('original')
        gallery.sample_photo_aspect_ratio = tempPhoto.aspect_ratio 
        gallery.put()
        db.delete(gallery.photos)
        # TODO: Convert this to a single put command to save them in batch
        photoList = []
        for fPhoto in photo_set.photos:
            photoList.append(Photo(parent=gallery,
                                   gallery=gallery,
                                   flickrPhotoId = fPhoto.id,
                                   title = (fPhoto.title if (fPhoto.title != None and fPhoto.title != "") else "Untitled"),
                                   description = fPhoto.description,
                                   aspect_ratio = fPhoto.aspect_ratio,
                                   flickrOwnerId = fPhoto.ownerId,
                                   flickrOwnerDisplayName = fPhoto.ownerDisplayName,
                                   flickrFarm = fPhoto.farm,
                                   flickrServer = fPhoto.server,
                                   flickrSecret = fPhoto.secret))
        db.put(photoList)
        gallery.put()
            
        # wtf... it seems like the iteration isn't starting from the beginning of the list because of the previous code
        end = datetime.datetime.now()
        logger.info("Ingestion for topic '" + topic + "' complete " + end.isoformat(' ') + "(" + str((end-start).seconds) + " seconds)")
        self.response.out.write("Ingested gallery for topic '" + topic + "' starts with " + gallery.starts_with)
