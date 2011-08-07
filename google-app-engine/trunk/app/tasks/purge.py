# tasks/purge.py
# View/Task to remove unneeded (old) galleries from the system 

import logging
import pprint
import datetime
from itertools import islice
from itertools import ifilter

from google.appengine.ext import db
from google.appengine.ext import webapp

from app.models.gallery import Gallery
from app.models.gallery import GalleryManager
from app.models.photo import Photo

logger = logging.getLogger('PrettyPrinter')
pprinter = pprint.PrettyPrinter(indent=4)

# date manipulation by month
# from: http://code.activestate.com/recipes/577274-subtract-or-add-a-month-to-a-datetimedate-or-datet/
def add_one_month(t):
    """Return a `datetime.date` or `datetime.datetime` (as given) that is
    one month earlier.
    
    Note that the resultant day of the month might change if the following
    month has fewer days:
    
        >>> add_one_month(datetime.date(2010, 1, 31))
        datetime.date(2010, 2, 28)
    """
    import datetime
    one_day = datetime.timedelta(days=1)
    one_month_later = t + one_day
    while one_month_later.month == t.month:  # advance to start of next month
        one_month_later += one_day
    target_month = one_month_later.month
    while one_month_later.day < t.day:  # advance to appropriate day
        one_month_later += one_day
        if one_month_later.month != target_month:  # gone too far
            one_month_later -= one_day
            break
    return one_month_later
475
def subtract_one_month(t):
    """Return a `datetime.date` or `datetime.datetime` (as given) that is
    one month later.
    
    Note that the resultant day of the month might change if the following
    month has fewer days:
    
        >>> subtract_one_month(datetime.date(2010, 3, 31))
        datetime.date(2010, 2, 28)
    """
    import datetime
    one_day = datetime.timedelta(days=1)
    one_month_earlier = t - one_day
    while one_month_earlier.month == t.month or one_month_earlier.day > t.day:
        one_month_earlier -= one_day
    return one_month_earlier


class PurgePage(webapp.RequestHandler): 
    def __init__(self):
        self.galleryManager = GalleryManager()

    def get(self):
        when = subtract_one_month(datetime.datetime.now())
        galleries = self.galleryManager.getGalleriesOlderThan(when)
        photos = [photo.key()
                  for gallery in galleries
                  for photo in gallery.photos]
        logger.info("Purging " + str(len(galleries)) + " galleries with " + str(len(photos)) + " photos")
        db.delete(photos)
        db.delete(galleries)
        self.response.out.write("Purged " + str(len(galleries)) + " galleries with " + str(len(photos)) + " photos")
