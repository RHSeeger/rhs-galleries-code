class HomeController < ApplicationController
    def index
        topicsList = Topics.where(:source => 'google')
        topicsObj = case topicsList.length
                    when 0 then
                        raise("No topics found for google")
                    when 1 then
                        topicsList[0]
                    else
                        raise("More than one set of topics found for google")
                    end
        
        #if the topics are old, schedule an update
        if(topicsObj.updated_at < (Time.now.getutc - (Settings['topics_age']))) then
            Rails.logger.info("Scheduling topic/gallery update")
            Rails.logger.info("updated_at: " + topicsObj.updated_at.to_s)
            Rails.logger.info("now: " + (Time.at(Time.now.getutc)).to_s)
            Rails.logger.info("maxage: " + Settings['topics_age'].to_s)
            Delayed::Job.enqueue GalleryUpdaterJob.new('google')
        else 
            Rails.logger.info("Not scheduling topic/gallery update")
            Rails.logger.info("updated_at: " + topicsObj.updated_at.to_s)
            Rails.logger.info("now: " + (Time.at(Time.now.getutc)).to_s)
            Rails.logger.info("maxage: " + Settings['topics_age'].to_s)
        end

        @galleries = Gallery.where(:source => 'flickr', :search => topicsObj.topics)

        respond_to do |format|
            format.html # show.html.erb
        end
    end

end
