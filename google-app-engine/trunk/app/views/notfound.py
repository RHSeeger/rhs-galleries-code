from google.appengine.ext.webapp import template
from google.appengine.ext import webapp
from app.common import get_template

import logging
logger = logging.getLogger('NotFoundPage')

class NotFoundPage(webapp.RequestHandler):
    def get(self):
        template_values = {'url' : self.request.url}
        template_file = get_template('404.html')
        self.error(404)
        self.response.out.write(template.render(template_file, template_values))
