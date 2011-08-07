require 'GalleryUpdater'
require 'pp'
require 'Settings'
# require 'Topics'
# require 'Processor'

class GalleryUpdaterJob < Struct.new(:source)

#    attr_accessor :source

    # def initialize(source)
    #     @source = source
    # end

    def perform
        record_stat 'gallery_updater_job/perform'
        # check if the topics for the source are out of date, if not return
        topics = Topics.where(:source => @source)
        case topics.length
        when 0 then # there were none, create some
        when 1 then # there was one, if it's recent, then return
            if (topics[0].updated_at >= (Time.now.getutc - (Settings['topics_age']))) then
                return
            end
        else
            raise("More than one topics entry for " + @source + " was found")
        end

        # try to get a lock and update the topics entry
        processor = Processor.start('galleries/' + source, (60*60))
        if(processor == nil) then # couldn't get a lock, another process is handling it
            Rails.logger.info("Could not get lock")
            return
        end

        Rails.logger.info("Got lock with processor: " + PP.pp(processor, ""))
        begin
            GalleryUpdater.new(source).update()
        rescue => exception
            Rails.logger.info("processor failed: " + exception.message + "\n" + exception.backtrace.join("\n"))
            processor.finish('failed')
            return
        end
        processor.finish('succeeded')
    end

    def enqueue(job)
        record_stat 'gallery_updater_job/enqueue'
    end

    def before(job)
        record_stat 'gallery_updater_job/start'
    end

    def after(job)
        record_stat 'gallery_updater_job/after'
    end

    def success(job)
        record_stat 'gallery_updater_job/success'
    end

    def error(job, exception)
        record_stat 'gallery_updater_job/error (' + exception.message + ')'
    end

    def failure
        record_stat 'gallery_updater_job/failure'
    end

    def record_stat(message)
        Rails.logger.info("GalleryUpdaterJob: " + message)
    end
end

# # Remove old jobs
# Delayed::Job.all.each do |job|
#     if(job.name == 'GalleryUpdaterJob') then
#         Rails.logger.info("Deleting job: " + job.name)
#         job.delete 
#     end
# end
# Delayed::Job.enqueue GalleryUpdaterJob.new('google')
