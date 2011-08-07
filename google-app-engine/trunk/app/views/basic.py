
from google.appengine.ext.webapp import template
from google.appengine.ext import webapp

from app.common import get_template

import logging
logger = logging.getLogger('BasicPage')

class BasicPage(webapp.RequestHandler): 
    def get(self, page):
        logger.info("page is '" + page + "'")
        template_values = { 'page' : page }
        template_file = get_template(page + '.html')
        self.response.out.write(template.render(template_file, template_values))

            

