import os
from google.appengine.ext import db

app_root = os.path.join(os.path.dirname(__file__))
paths_templates = os.path.join(app_root, 'templates')
paths_models = os.path.join(app_root, 'models')

def get_template(name):
    return os.path.join(paths_templates, name)

def guestbook_key(guestbook_name=None):
  """Constructs a datastore key for a Guestbook entity with guestbook_name."""
  return db.Key.from_path('Guestbook', guestbook_name or 'default_guestbook')
