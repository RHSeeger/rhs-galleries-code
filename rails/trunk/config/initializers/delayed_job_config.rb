# Delayed::Worker.destroy_failed_jobs = false  
Delayed::Worker.logger = Rails.logger

require 'GalleryUpdaterJob'
#require Rails.root.join('lib', 'DelayedUpdaterJob')

