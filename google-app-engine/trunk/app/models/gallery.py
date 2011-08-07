from google.appengine.ext import db
import string
import logging
import random
logger = logging.getLogger('FlickrImageSource')

# returns the lower case version of the letter this topic starts with
# or "other"
def starts_with(topic):
    if(topic == None or len(topic) == 0):
        raise "empty topic"
    lowered = string.lower(topic)[0]
    if(lowered < 'a' or lowered > 'z'):
        return 'other'
    else:
        return lowered

class Gallery(db.Model):
    search_term = db.StringProperty(required=True)
    starts_with = db.StringProperty(required=False) # the lower case letter this gallery topic starts with, or "other"
    sample_photo_url = db.StringProperty(required=True)
    sample_photo_aspect_ratio = db.FloatProperty(required=False)
    ts_created = db.DateTimeProperty(required=True, auto_now_add=True)
    ts_modified = db.DateTimeProperty(required=True, auto_now=True)
    # photos = list of Photo objects

class GalleryManager:
    def getRecentGalleries(self, count):
        q = db.GqlQuery("SELECT * FROM Gallery ORDER BY ts_modified DESC")
        return q.fetch(count)

    def getGallery(self, topic):
        q = db.GqlQuery("SELECT * FROM Gallery WHERE search_term = :1", topic)
        result = q.fetch(1)
        if len(result) == 1:
            logger.info("Found 1 gallery found for topic '" + topic + "'")
            return result[0]
        elif len(result) > 1:
            raise "Got " + len(result) + " result back"
        else:
            logger.info("No gallery found for topic '" + topic + "'")
            return None

    def getRandomGallery(self):
        random.seed(None)
        offset = random.randint(0, 1000)
        q = db.GqlQuery("SELECT * FROM Gallery ORDER BY ts_modified")
        result = q.fetch(1, offset)
        if len(result) == 1:
            logger.info("Found 1 random gallery found with topic '" + result[0].search_term + "' (offset:" + str(offset) + ")")
            return result[0]
        elif len(result) > 1:
            raise "Got " + len(result) + " result back"
        else:
            logger.info("No random gallery found")
            return None
 
    def getGalleriesOlderThan(self, when):
        q = db.GqlQuery("SELECT * FROM Gallery WHERE ts_modified < :1", when)
        return q.fetch(100)
    
    def getGalleriesStartingWith(self, letter):
        q = db.GqlQuery("SELECT * FROM Gallery WHERE starts_with >= :1 AND starts_with <= :2 ORDER BY starts_with, search_term DESC", letter, letter)
        return q.fetch(1000)
