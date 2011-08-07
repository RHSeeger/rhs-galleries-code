from google.appengine.ext.webapp import template
from google.appengine.ext import webapp
import time

from app.models.gallery import GalleryManager
from app.models.gallery import Gallery
# from app import common
from app.common import get_template

import logging
logger = logging.getLogger('FlickrImageSource')

class MainPage(webapp.RequestHandler):
    def get(self):
        galleryManager = GalleryManager()
        galleries = galleryManager.getRecentGalleries(20)
        other_galleries = sorted(galleries[6:], lambda x,y : cmp(x.search_term, y.search_term))
        #float(lt.strftime('%s'))
        min_date = min([time.mktime(gallery.ts_modified.timetuple()) for gallery in other_galleries if gallery.ts_modified != None])
        max_date = max([time.mktime(gallery.ts_modified.timetuple()) for gallery in other_galleries if gallery.ts_modified != None])
        for gallery in other_galleries:
            if max_date == min_date:
                gallery.weight = 0
            else:
                gallery.weight = 1 + int(4 * (time.mktime(gallery.ts_modified.timetuple()) - min_date) / (max_date - min_date) )
#        for gallery in galleries:
#            for photo in gallery.photos:
#                logger.info("photo: " + photo.getUrl('original'))
                
        template_values = {'galleries' : galleries[0:6], 
                           'other_galleries' : other_galleries,
                           'page' : 'main'}
        template_file = get_template('main.html')
        self.response.out.write(template.render(template_file, template_values))
