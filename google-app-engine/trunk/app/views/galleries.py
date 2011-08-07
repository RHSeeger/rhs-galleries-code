from google.appengine.ext.webapp import template
from google.appengine.ext import webapp

from app.models.gallery import GalleryManager
from app.common import get_template

import logging
logger = logging.getLogger('GalleriesPage')

class GalleriesPage(webapp.RequestHandler): 
    def get(self, letter):
        galleryManager = GalleryManager()
        galleries = galleryManager.getGalleriesStartingWith(letter)
        logger.info("Retrieving galleries starting with: " + letter)
        template_values = {'galleries' : galleries, 'page' : 'galleries', 'starts_with' : letter}
        template_file = get_template('galleries.html')
        self.response.out.write(template.render(template_file, template_values))

