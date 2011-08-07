import logging
import pprint
import datetime

from google.appengine.ext import webapp
from google.appengine.api import taskqueue

from app.managers.topicsource import TopicSource

logger = logging.getLogger('IngestPage')
pprinter = pprint.PrettyPrinter(indent=4)

class IngestPage(webapp.RequestHandler): 

    def get(self):
        #db.delete(db.GqlQuery("SELECT * FROM Gallery").fetch(1000))
        #db.delete(db.GqlQuery("SELECT * FROM Photo").fetch(1000))
        #logger.info("sys.path=\n\t" + "\n\t".join(sys.path))
        #logger.info("os.env=\n\t" + "\n\t".join([(k + "=" + os.environ[k]) for k in os.environ]))
        start = datetime.datetime.now()
        logger.info('Running ingestion at ' + start.isoformat(' '))
        topics = TopicSource().getTopics()[0:6]
        for topic in reversed(topics):
            logger.info("Enqueing gallery ingestion for topic '" + topic + "'")
            taskqueue.add(url='/tasks/ingestgallery', params={'topic': topic})
        end = datetime.datetime.now()
        logger.info("Ingestion complete " + end.isoformat(' ') + "(" + str((end-start).seconds) + " seconds): (" + ', '.join(topics) + ")")
        self.response.out.write('ingestion complete. topics: ' + ', '.join(topics))
