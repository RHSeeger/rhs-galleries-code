from google.appengine.dist import use_library
use_library('django', '1.2')

from app.views.gallery import GalleryPage
from app.views.galleries import GalleriesPage
from app.views.random import RandomGalleryPage
from app.views.main import MainPage
from app.views.basic import BasicPage
from app.views.notfound import NotFoundPage
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
import logging

logging.getLogger('anonymous').info("In /main.py")

application = webapp.WSGIApplication([
  ('/', MainPage),
  ('/gallery/([^/?]+)(\\?.*)?$', GalleryPage),
  ('/randomgallery/?(\\?.*)?$', RandomGalleryPage),
  ('/galleries/([a-z]|other)$', GalleriesPage),
  ('/(about|faq|privacy)', BasicPage),
  ('/.*', NotFoundPage)
], debug=True)

def main():
    run_wsgi_app(application)

if __name__ == '__main__':
    main()
