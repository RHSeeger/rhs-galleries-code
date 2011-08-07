class GalleryController < ApplicationController
    def index
        @gallery = Gallery.where(:search => params[:searchterm]).first
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @gallery }
        end

    end
end
