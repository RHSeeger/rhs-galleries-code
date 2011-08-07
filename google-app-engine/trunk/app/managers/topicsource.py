from django.utils import simplejson as json
from google.appengine.api import urlfetch

import logging
logger = logging.getLogger('TopicSource')

twitter_topic_url = {
                     "current" : "http://api.twitter.com/1/trends/current.json?exclude=hashtags",
                     "daily" : "http://api.twitter.com/1/trends/daily.json?exclude=hashtags",
                     "weekly" : "http://api.twitter.com/1/trends/wkkely.json?exclude=hashtags"
                     }

def unquote(str):
    """Removes the leading/training quotes from a string, if it has them"""
    if(str.startswith('"') and str.endswith('"')):
        return str[1:-1]
    else:
        return str

class TopicSource:
    def getTopics(self):
        return self.getTopicsCurrent()
    
    def getTopicsCurrent(self):
        results = []
        twitter = urlfetch.fetch(twitter_topic_url['current'])
        if twitter.status_code != 200:
            raise "Could not load Twitter trend data"
        logger.info(twitter_topic_url['current'] + "->" + twitter.content)
        obj = json.loads( twitter.content )
        for date in obj['trends']:
            for entry in obj['trends'][date]:
                try:
                    results.append(unquote(entry['query'].decode('ascii')))
                except:
                    # It wasn't ascii
                    pass
        return results
    
    def getTopicsDaily(self):
        results = []
        twitter = urlfetch.fetch(twitter_topic_url['daily'])
        if twitter.status_code != 200:
            raise "Could not load Twitter trend data"
        logger.info(twitter_topic_url['daily'] + "->" + twitter.content)
        obj = json.loads( twitter.content )
        for date in obj['trends']:
            for entry in obj['trends'][date]:
                results.append(unquote(entry['query']))
        return results
