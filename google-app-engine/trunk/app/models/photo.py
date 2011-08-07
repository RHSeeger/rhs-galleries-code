from google.appengine.ext import db
from app.models.gallery import Gallery

_sizes = {
          'thumbnail' : "t",
          'tiny' : "s",
          'small' : "m",
          'medium' : "-", # this doesn't seem to work
          'large' : "z",
          'huge' : "b",
          'original' : "o"
          }

class Photo(db.Model):
    flickrPhotoId = db.StringProperty(required=True)
    title = db.StringProperty(required=True)
    description = db.TextProperty(required=False)
    aspect_ratio = db.FloatProperty(required=False)
    flickrOwnerId = db.StringProperty(required=True)
    flickrOwnerDisplayName = db.StringProperty(required=True)
    flickrFarm = db.StringProperty(required=True)
    flickrServer = db.StringProperty(required=True)
    flickrSecret = db.StringProperty(required=True)
    gallery = db.ReferenceProperty(Gallery, collection_name="photos")

    # http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}.jpg
    # or
    # http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
    # or
    # http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)  this doesn't seem to work
    def getUrl(self, size):
        if(size == 'original'):
            return "http://farm" + self.flickrFarm + ".static.flickr.com/" + self.flickrServer + "/" + self.flickrPhotoId + "_" + self.flickrSecret + ".jpg";
        else:
            return "http://farm" + self.flickrFarm + ".static.flickr.com/" + self.flickrServer + "/" + self.flickrPhotoId + "_" + self.flickrSecret + "_" + _sizes[size] + ".jpg";

    # return a map of all the urls
    def getUrls(self):
        urls = {}
        for size,url in _sizes.iteritems():
            urls[size] = self.getUrl(size)
        return urls

    def getLinkbackUrl(self):
        return "http://www.flickr.com/photos/" + self.flickrOwnerId + '/' + self.flickrPhotoId;

