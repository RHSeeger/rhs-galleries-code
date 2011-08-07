require 'GalleryUpdaterJob'

class AdminController < ApplicationController
    def index
        # Processor.all.each { |process| process.delete }
        # GalleryUpdaterJob.new('google').perform
        Delayed::Job.enqueue GalleryUpdaterJob.new('google')
    end

end
