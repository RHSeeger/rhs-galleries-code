require 'GoogleTopics'
require 'FlickrApi'
require 'Settings'
require 'pp'

class GalleryUpdater
    attr_reader :source

    def initialize(source)
        @source = source
    end

    def update()
        topics = case @source
                 when 'google' then
                     GoogleTopics.new().getHotTopics()
                 else
                     raise "Unknown topic source: " + @source
                 end
        Rails.logger.info("updating " + source.to_s + " topics: " + topics.join(", "))

        imagesMap = getImages(topics)
        Rails.logger.info("images: " + PP.pp(imagesMap, ""))

        saveGalleriesToDb(imagesMap)

        topicsList = Topics.where(:source => @source)
        topics = case topicsList.length
                 when 0 then
                     Topics.new(:source => @source)

                 when 1 then
                     topicsList[0]
                 else
                     raise("More than one topics list found for " + @source)
                 end
        topics.topics = imagesMap.map { |term,images| term }
        topics.save!
    end

    def getImages(topics) 
        flickr = FlickrApi.new(Settings['flickr_key'])
        result = Hash.new()
        topics.each do |topic|
            images = flickr.photos('text'=>topic, 
                                   'per_page'=>'10', 
                                   'content_type' => '1', 
                                   'sort' => 'relevance', 
                                   'media' => 'photos')
            if(images.length < 10) then
                continue
            end

            result[topic] = images.map do |image|
                image_meta = flickr.photos_getInfo('photo_id'=>image.photo_id)['photo']
                Image.new(:flickrPhotoId => image.photo_id,
                          :flickrServer  => image.server,
                          :flickrFarm    => image.farm,
                          :flickrSecret  => image.secret,
                          :flickrOwnerId => image.owner,
                          :caption       => "not available yet",
                          :title         => image_meta['title'],
                          :description   => image_meta['description'],
                          :user          => image_meta['owner']['username'])
            end

            if(result.length >= 6) then
                return result
            end
        end
    end

    def saveGalleriesToDb(imagesMap)
        terms = imagesMap.map { |term,images| term }
        dbgalleries = Gallery.where(:search => terms)
        dbgalleriesMap = Hash[dbgalleries.map {|gallery| [gallery.search, gallery]}]

        imagesMap.each do |topic,imageList|
            gallery = if(dbgalleriesMap.has_key?(topic)) then
                          dbgalleriesMap[topic] # update gallery
                      else # create new gallery
                          Gallery.new(:source => "flickr", :search => topic)
                      end
            gallery.images = imageList
            gallery.updated_at = Time.now.getutc
            gallery.save!
        end
    end
end

# ######
# GalleriesMetaController
# ######
# require 'date'

# class GalleriesMetaController < ApplicationController
#   def index
#     terms = params[:term]
#     dbgalleries = DynamicGallery.where(:search => terms)
#     dbgallery_map = Hash[dbgalleries.map {|gallery| [gallery.search, gallery]}]
    
#     @galleries = terms.map do |term|
#       if(dbgallery_map.has_key?(term) && dbgallery_map[term].updated_at >= (Time.now.getutc - (Settings['flickr_timeout'])) ) then # its valid, use it
#           dbgallery_map[term]
#       else 
#           gallery = if(dbgallery_map.has_key?(term)) then
#                         dbgallery_map[term] # update gallery
#                     else # create new gallery
#                         DynamicGallery.new(:source => "flickr", :search => term)
#                     end
#           images = FlickrApi.new(Settings['flickr_key']).photos('text'=>term, 
#                                                                 'per_page'=>'10', 
#                                                                 'content_type' => '1', 
#                                                                 'sort' => 'relevance', 
#                                                                 'media' => 'photos')
                                   
#           gallery.images = images.map do |flickrImage|
#               Image.new(:flickrPhotoId => flickrImage.photo_id,
#                         :flickrServer => flickrImage.server,
#                         :flickrFarm => flickrImage.farm,
#                         :flickrSecret => flickrImage.secret,
#                         :flickrOwnerId => flickrImage.owner,
#                         :caption => "not available yet",
#                         :title => flickrImage.title,
#                         :description => "not available yet",
#                         :photographer => flickrImage.owner)
#           end
#         gallery.updated_at = Time.now.getutc
#         gallery.save
#         gallery
#       end
#     end
#     @galleries1 = @galleries.find_all {|gallery| gallery.images.length > 0 }.first(6).map do |gallery|
#         {
#             'link' => '/gallery/' + gallery.search,
#             'image' => gallery.images.first.url(:original),
#             'searchterm' => gallery.search
#         }
#     end
#     Thread.new { ImageMetadataPopulator.new(@galleries.map {|gallery| gallery.id}).process }
#     RAILS_DEFAULT_LOGGER.info("galleries: " + PP.pp(@galleries1, ""))
    
#     respond_to do |format|  
#       format.js { render_json @galleries1.to_json }  
#     end  
#   end  
# end

# ########################################
# ImageMetadataPopulator
# ########################################
# ActiveSupport::Dependencies.load_file "Settings.rb" if "development" == RAILS_ENV
# require 'pp'

# class ImageMetadataPopulator
#     attr_accessor :gallery_ids
    
#     def initialize(gallery_ids)
#         @gallery_ids = gallery_ids
#     end
  
#     def process()
#         begin
#             flickr = FlickrApi.new(Settings['flickr_key'])
#             DynamicGallery.where(:id => gallery_ids).each do |gallery|
#                 gallery.images.each do |image|
#                     image_meta = flickr.photos_getInfo('photo_id'=>image.flickrPhotoId)['photo']
#                     image.title = image_meta['title']
#                     image.description = image_meta['description']
#                     image.photographer = image_meta['owner']['username']
#                     RAILS_DEFAULT_LOGGER.info("Found gallery (#{gallery.id}) image " + PP.pp(image, ""))
#                     image.save!
#                 end
#                 RAILS_DEFAULT_LOGGER.info("ImageMetadataPopulator: Saving gallery: " + PP.pp(gallery, ""))
#                 gallery.save!
#                 RAILS_DEFAULT_LOGGER.info("ImageMetadataPopulator: Saved gallery: " + PP.pp(gallery, ""))
#             end
#         rescue Exception => exception
#             RAILS_DEFAULT_LOGGER.info("ImageMetadataPopulator:There was an exception!! #{exception.message}\n" + exception.backtrace.join("\n"))
#         end
#     end
# end
