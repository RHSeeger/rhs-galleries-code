from google.appengine.dist import use_library
use_library('django', '1.2')

import sys
sys.path.insert(0, 'lib')

import logging
logging.getLogger('anonymous').info("In app/tasks/main.py")

from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

from app.tasks.ingest import IngestPage
from app.tasks.purge import PurgePage
from app.tasks.ingestgallery import IngestGalleryPage

application = webapp.WSGIApplication([
  ('/tasks/ingest', IngestPage),
  ('/tasks/ingestgallery', IngestGalleryPage),
  ('/tasks/purge', PurgePage)
], debug=True)

def main():
    run_wsgi_app(application)

if __name__ == '__main__':
    main()
else:
    raise "omg wtf, not main in tasks/main.py"
