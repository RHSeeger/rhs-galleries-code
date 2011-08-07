
from google.appengine.ext.webapp import template
from google.appengine.ext import webapp

from app.models.gallery import GalleryManager
from app.common import get_template

import logging
logger = logging.getLogger('RandomGalleryPage')

class RandomGalleryPage(webapp.RequestHandler): 
    def get(self,ignore):
        galleryManager = GalleryManager()
        logger.info("random gallery");
        gallery = galleryManager.getRandomGallery()
        self.redirect("/gallery/" + gallery.search_term)

#        logger.info("Found gallery for " + gallery.search_term + " objectclass = " + gallery.__class__.__name__)
#        template_values = {'gallery' : gallery, 'page' : 'gallery'}
#        template_file = get_template('gallery.html')
#        self.response.out.write(template.render(template_file, template_values))

