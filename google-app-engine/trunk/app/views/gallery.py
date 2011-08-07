
from google.appengine.ext.webapp import template
from google.appengine.ext import webapp

from app.models.gallery import GalleryManager
from app.models.gallery import Gallery
# from app import common
from app.common import get_template
from urllib import unquote

import logging
logger = logging.getLogger('FlickrImageSource')

class GalleryPage(webapp.RequestHandler): 
    def get(self, topic, ignore):
        topic = unquote(topic)
        galleryManager = GalleryManager()
        logger.info("gallery topic: " + topic);
        gallery = galleryManager.getGallery(topic)
        
        if gallery != None:
            logger.info("Found gallery for " + gallery.search_term + " objectclass = " + gallery.__class__.__name__)
#            for photo in gallery.photos:
#                logger.info("photo: " + photo.getUrl('original'))
            template_values = {'gallery' : gallery, 'page' : 'gallery'}
            template_file = get_template('gallery.html')
            self.response.out.write(template.render(template_file, template_values))
        else:
            logger.info("Did not find gallery for " + topic + " - using dynamic gallery view")
            template_values = {'topic' : topic, 'page' : 'gallery'}
            template_file = get_template('gallery_dynamic.html')
            self.response.out.write(template.render(template_file, template_values))
            

