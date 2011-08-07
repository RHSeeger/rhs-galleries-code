#  - seek feedback from somebody
#  - make a kickass demo, including autocompleting-ajax photo lookup ala http://mir.aculo.us/images/autocomplete1.mov

require 'cgi'
require 'net/http'
require 'xmlsimple'
require 'logger'
require 'pp'

# Flickr client class. Requires an API key, and optionally takes an email and password for authentication
class FlickrApi

    attr_accessor :user

    # Replace this API key with your own (see http://www.flickr.com/services/api/misc.api_keys.html)
    def initialize(api_key=nil, email=nil, password=nil)
        @api_key = api_key
        #@host = 'http://flickr.com'
        @host='http://api.flickr.com'
        @api = '/services/rest'
        login(email, password) if email and password
    end

    # Takes a Flickr API method name and set of parameters; returns an XmlSimple object with the response
    def request(method, *params)
        # Rails.logger.info("URL: " + request_url(method, params));
        xml = http_get(request_url(method, params))
        response = XmlSimple.xml_in(xml, { 'ForceArray' => false })
        raise response['err']['msg'] if response['stat'] != 'ok'
        response
    end
    
    # Takes a Flickr API method name and set of parameters; returns the correct URL for the REST API.
    # If @email and @password are present, authentication information is included
    def request_url(method, *params)
        url = "#{@host}#{@api}/?api_key=#{@api_key}&method=flickr.#{method}"
        params[0][0].each_key do |key| url += "&#{key}=" + CGI::escape(params[0][0][key]) end if params[0][0]
        url += "&email=#{@email}&password=#{@password}" if @email and @password
        url
    end
    
    # Does an HTTP GET on a given URL and returns the response body
    def http_get(url)
        Net::HTTP.get_response(URI.parse(url)).body.to_s
    end

    # Stores authentication credentials to use on all subsequent calls.
    # If authentication succeeds, returns a User object
    def login(email='', password='')
        @email = email
        @password = password
        user = request('test.login')['user'] rescue fail
        @user = User.new(user['id'], @api_key)
    end
    
    # Implements flickr.urls.lookupGroup and flickr.urls.lookupUser
    def find_by_url(url)
        response = urls_lookupUser('url'=>url) rescue urls_lookupGroup('url'=>url) rescue nil
        (response['user']) ? User.new(response['user']['id'], @api_key) : Group.new(response['group']['id'], @api_key) unless response.nil?
    end

    # Implements flickr.photos.getRecent and flickr.photos.search
    def photos(*criteria)
        Rails.logger.info("API KEY: " + (@api_key ? @api_key : 'null'))
        Rails.logger.info("criteria: " + criteria.to_s)
        photos_data = (criteria[0]) ? photos_search(criteria[0]) : photos_getRecent
        # At this point, search criterias with pet_page => has structure
        # {"photos => {"photo" => {...}}"} 
        # While per_page values with > 1 have
        # {"photos => {"photo" => [{...}]}"}
        Rails.logger.info("STAT: " + photos_data['stat'])
        Rails.logger.info("FULL DATA STRUCTURE: " + PP.pp(photos_data,"")) 
        Rails.logger.info("PHOTOS: " + photos_data['stat'] + " -> " + PP.pp(photos_data['photos'],"")) 

        photos = photos_data['photos']['photo']
        photos = if(photos.nil?) then # no photos
                     Rails.logger.info("NO PHOTOS")
                     []
                 elsif(photos.instance_of?(Array)) then # list of photos
                     Rails.logger.info("MULTIPLE PHOTOS")
                     photos
                 else #single photo
                     Rails.logger.info("ONE PHOTO")
                     [photos]
                 end
        Rails.logger.info("PHOTOS IS NOW: " + PP.pp(photos, ""))           
        return photos.collect do |photo| 
            SimplePhoto.new(photo)
        end
        #Rails.logger.info("DONE")
    end

    # Gets public photos with a given tag
    def tag(tag)
        photos('tags'=>tag, 'per_page'=>'10')
    end
    
    # Implements flickr.people.getOnlineList, flickr.people.findByEmail, and flickr.people.findByUsername
    def users(lookup=nil)
        if(lookup)
            user = people_findByEmail('find_email'=>lookup)['user'] rescue people_findByUsername('username'=>lookup)['user']
            return User.new(user['nsid'], @api_key)
        else
            return people_getOnlineList['online']['user'].collect { |person| User.new(person['nsid'], @api_key) }
        end
    end

    # Implements flickr.groups.getActiveList
    def groups
        groups_getActiveList['activegroups']['group'].collect { |group| Group.new(group['nsid'], @api_key) }
    end
    
    # Implements flickr.tags.getRelated
    def related_tags(tag)
        tags_getRelated('tag_id'=>tag)['tags']['tag']
    end
    
    # Implements flickr.photos.licenses.getInfo
    def licenses
        photos_licenses_getInfo['licenses']['license']
    end
    
    # Implements everything else.
    # Any method not defined explicitly will be passed on to the Flickr API,
    # and return an XmlSimple document. For example, Flickr#test_echo is not defined,
    # so it will pass the call to the flickr.test.echo method.
    # e.g., Flickr#test_echo['stat'] should == 'ok'
    def method_missing(method_id, *params)
        request(method_id.id2name.gsub(/_/, '.'), params[0])
    end

    # Todo:
    # logged_in?
    # if logged in:
    # flickr.blogs.getList
    # flickr.favorites.add
    # flickr.favorites.remove
    # flickr.groups.browse
    # flickr.photos.getCounts
    # flickr.photos.getNotInSet
    # flickr.photos.getUntagged
    # flickr.photosets.create
    # flickr.photosets.orderSets
    # flickr.tags.getListUserPopular
    # flickr.test.login
    # uploading
    class User
        
        attr_reader :client, :id, :name, :location, :photos_url, :url, :count, :firstdate, :firstdatetaken

        def initialize(id=nil, username=nil, email=nil, password=nil, api_key=nil)
            @id = id
            @username = username
            @email = email
            @password = password
            @client = Flickr.new @api_key
            @client.login(email, password) if email and password
            @api_key = api_key
        end

        def username
            @username.nil? ? getInfo.username : @username
        end
        def name
            @name.nil? ? getInfo.name : @name
        end
        def location
            @location.nil? ? getInfo.location : @location
        end
        def count
            @count.nil? ? getInfo.count : @count
        end
        def firstdate
            @firstdate.nil? ? getInfo.firstdate : @firstdate
        end
        def firstdatetaken
            @firstdatetaken.nil? ? getInfo.firstdatetaken : @firstdatetaken
        end
        def photos_url
            @photos_url.nil? ? getInfo.photos_url : @photos_url
        end
        def url
            @url.nil? ? getInfo.url : @url
        end
        
        # Implements flickr.people.getPublicGroups
        def groups
            @client.people_getPublicGroups('user_id'=>@id)['groups']['group'].collect { |group| Group.new(group['nsid'], @api_key) }
        end
        
        # Implements flickr.people.getPublicPhotos
        def photos
            @client.people_getPublicPhotos('user_id'=>@id)['photos']['photo'].collect { |photo| Photo.new(photo['id'], @api_key) }
            # what about non-public photos?
        end

        # Gets photos with a given tag
        def tag(tag)
            @client.photos('user_id'=>@id, 'tags'=>tag)
        end

        # Implements flickr.contacts.getPublicList and flickr.contacts.getList
        def contacts
            @client.contacts_getPublicList('user_id'=>@id)['contacts']['contact'].collect { |contact| User.new(contact['nsid'], @api_key) }
            #or
        end
        
        # Implements flickr.favorites.getPublicList and flickr.favorites.getList
        def favorites
            @client.favorites_getPublicList('user_id'=>@id)['photos']['photo'].collect { |photo| Photo.new(photo['id'], @api_key) }
            #or
        end
        
        # Implements flickr.photosets.getList
        def photosets
            @client.photosets_getList('user_id'=>@id)['photosets']['photoset'].collect { |photoset| Photoset.new(photoset['id'], @api_key) }
        end

        # Implements flickr.tags.getListUser
        def tags
            @client.tags_getListUser('user_id'=>@id)['who']['tags']['tag'].collect { |tag| tag }
        end

        # Implements flickr.photos.getContactsPublicPhotos and flickr.photos.getContactsPhotos
        def contactsPhotos
            @client.photos_getContactsPublicPhotos('user_id'=>@id)['photos']['photo'].collect { |photo| Photo.new(photo['id'], @api_key) }
            # or
            #@client.photos_getContactsPhotos['photos']['photo'].collect { |photo| Photo.new(photo['id'], @api_key) }
        end
        
        def to_s
            @name
        end

        private

        # Implements flickr.people.getInfo, flickr.urls.getUserPhotos, and flickr.urls.getUserProfile
        def getInfo
            info = @client.people_getInfo('user_id'=>@id)['person']
            @username = info['username']
            @name = info['realname']
            @location = info['location']
            @count = info['photos']['count']
            @firstdate = info['photos']['firstdate']
            @firstdatetaken = info['photos']['firstdatetaken']
            @photos_url = @client.urls_getUserPhotos('user_id'=>@id)['user']['url']
            @url = @client.urls_getUserProfile('user_id'=>@id)['user']['url']
            self
        end

    end

    class SimplePhoto
        attr_reader :photo_id, :owner, :secret, :server, :farm, :title, :ispublic, :isfriend, :isfamily, :linkback
        
        def initialize(photo)
            Rails.logger.info("creating photo from: " + PP.pp(photo, ""))
            @photo_id = photo['id']
            @owner = photo['owner']
            @secret = photo['secret']
            @server = photo['server']
            @farm = photo['farm']
            @title = photo['title']
            @ispublic = photo['ispublic']
            @isfriend = photo['isfriend']
            @isfamily = photo['isfamily']
        end
    end
    
    class PhotoMeta
        attr_reader :title, :description, :caption
        def initialize(caption, title, description)
            @caption = caption
            @title = title
            @description = description
        end
    end
    
    
    
    class Photo

        attr_reader :id, :client

        def initialize(id=nil, api_key=nil)
            @id = id
            @api_key = api_key
            @client = Flickr.new @api_key
        end
        
        def title
            @title.nil? ? getInfo.title : @title
        end

        def owner
            @owner.nil? ? getInfo.owner : @owner
        end

        def server
            @server.nil? ? getInfo.server : @server
        end

        def isfavorite
            @isfavorite.nil? ? getInfo.isfavorite : @isfavorite
        end

        def license
            @license.nil? ? getInfo.license : @license
        end

        def rotation
            @rotation.nil? ? getInfo.rotation : @rotation
        end

        def description
            @description.nil? ? getInfo.description : @description
        end

        def notes
            @notes.nil? ? getInfo.notes : @notes
        end

        # Returns the URL for the photo page (default or any specified size)
        def url(size='Medium')
            if size=='Medium'
                "http://flickr.com/photos/#{owner.username}/#{@id}"
            else
                sizes(size)['url']
            end
        end

        # Returns the URL for the image (default or any specified size)
        def source(size='Medium')
            sizes(size)['source']
        end

        # Returns the photo file data itself, in any specified size. Example: File.open(photo.title, 'w') { |f| f.puts photo.file }
        def file(size='Medium')
            Net::HTTP.get_response(URI.parse(source(size))).body
        end

        # Unique filename for the image, based on the Flickr NSID
        def filename
            "#{@id}.jpg"
        end

        # Implements flickr.photos.getContext
        def context
            context = @client.photos_getContext('photo_id'=>@id)
            @previousPhoto = Photo.new(context['prevphoto']['id'], @api_key)
            @nextPhoto = Photo.new(context['nextphoto']['id'], @api_key)
            return [@previousPhoto, @nextPhoto]
        end

        # Implements flickr.photos.getExif
        def exif
            @client.photos_getExif('photo_id'=>@id)['photo']
        end

        # Implements flickr.photos.getPerms
        def permissions
            @client.photos_getPerms('photo_id'=>@id)['perms']
        end

        # Implements flickr.photos.getSizes
        def sizes(size=nil)
            sizes = @client.photos_getSizes('photo_id'=>@id)['sizes']['size']
            sizes = sizes.find{|asize| asize['label']==size} if size
            return sizes
        end

        # flickr.tags.getListPhoto
        def tags
            @client.tags_getListPhoto('photo_id'=>@id)['photo']['tags']
        end

        # Implements flickr.photos.notes.add
        def add_note(note)
        end
        
        # Implements flickr.photos.setDates
        def dates=(dates)
        end

        # Implements flickr.photos.setPerms
        def perms=(perms)
        end
        
        # Implements flickr.photos.setTags
        def tags=(tags)
        end
        
        # Implements flickr.photos.setMeta
        def title=(title)
        end
        def description=(title)
        end

        # Implements flickr.photos.addTags
        def add_tag(tag)
        end
        
        # Implements flickr.photos.removeTag
        def remove_tag(tag)
        end

        # Implements flickr.photos.transform.rotate
        def rotate
        end

        # Implements flickr.blogs.postPhoto
        def postToBlog(blog_id, title='', description='')
            @client.blogs_postPhoto('photo_id'=>@id, 'title'=>title, 'description'=>description)
        end

        # Implements flickr.photos.notes.delete
        def deleteNote(note_id)
        end

        # Implements flickr.photos.notes.edit
        def editNote(note_id)
        end
        
        # Converts the Photo to a string by returning its title
        def to_s
            getInfo.title
        end
        
        private

        # Implements flickr.photos.getInfo
        def getInfo
            info = @client.photos_getInfo('photo_id'=>@id)['photo']
            @title = info['title']
            @owner = User.new(info['owner']['nsid'], @api_key)
            @server = info['server']
            @isfavorite = info['isfavorite']
            @license = info['license']
            @rotation = info['rotation']
            @description = info['description']
            @notes = info['notes']['note']#.collect { |note| Note.new(note.id) }
            self
        end

    end

    # Todo:
    # flickr.groups.pools.add
    # flickr.groups.pools.getContext
    # flickr.groups.pools.getGroups
    # flickr.groups.pools.getPhotos
    # flickr.groups.pools.remove
    class Group
        attr_reader :id, :client, :name, :members, :online, :privacy, :chatid, :chatcount, :url
        
        def initialize(id=nil, api_key=nil)
            @id = id
            @api_key = api_key      
            @client = Flickr.new @api_key
        end

        # Implements flickr.groups.getInfo and flickr.urls.getGroup
        # private, once we can call it as needed
        def getInfo
            info = @client.groups_getInfo('group_id'=>@id)['group']
            @name = info['name']
            @members = info['members']
            @online = info['online']
            @privacy = info['privacy']
            @chatid = info['chatid']
            @chatcount = info['chatcount']
            @url = @client.urls_getGroup('group_id'=>@id)['group']['url']
            self
        end

    end

    # Todo:
    # flickr.photosets.delete
    # flickr.photosets.editMeta
    # flickr.photosets.editPhotos
    # flickr.photosets.getContext
    # flickr.photosets.getInfo
    # flickr.photosets.getPhotos
    class Photoset

        attr_reader :id, :client, :owner, :primary, :photos, :title, :description, :url

        def initialize(id=nil, api_key=nil)
            @id = id
            @api_key = api_key
            @client = Flickr.new @api_key
        end

        # Implements flickr.photosets.getInfo
        # private, once we can call it as needed
        def getInfo
            info = @client.photosets_getInfo('photosets_id'=>@id)['photoset']
            @owner = User.new(info['owner'], @api_key)
            @primary = info['primary']
            @photos = info['photos']
            @title = info['title']
            @description = info['description']
            @url = "http://www.flickr.com/photos/#{@owner.getInfo.username}/sets/#{@id}/"
            self
        end

    end
    
end
