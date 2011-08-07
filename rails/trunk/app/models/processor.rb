require 'pp'

class Processor < ActiveRecord::Base
    validates_uniqueness_of :process_name

    # Tries to lock the process and mark it as in progress
    # name - the name of the process
    # duration - how long until the process is considered to have run too long, in seconds
    # Return the process object created
    #        nil if it fails to lock (ie, it's already locked)
    def self.start(process_name, duration)
        createIfNotExists(process_name)

        now = Time.at(Time.now.getutc)
        expires = Time.at(now.getutc + duration)

        sql = <<"EOF"
UPDATE processors
SET locked_at = '#{now}',
    started_at = '#{now}',
    status = NULL,
    finished_at = NULL,
    expires_at = '#{expires}',
    updated_at = '#{now}'
WHERE process_name = '#{process_name}'
  AND locked_at IS NULL
EOF
        
        Rails.logger.info("Trying sql: " + sql)
        rows_updated = connection.update(sql) # Executes the update statement and returns the number of rows affected     
        Rails.logger.info("Finished sql. Rows update = " + rows_updated.to_s)

        if(rows_updated == 0) then
            return nil
        end

        processes = Processor.where(:process_name => process_name)
        case processes.length
        when 0 then
            raise("Didn't find the process row we just modified")
        when 1 then
            return processes[0]
        else
            raise("Found more than one matching process row")
        end
    end

    # Marks a process finished and unlocks it
    def finish(status)
        Rails.logger.info("Saving state (#{status}) of Processor: " + PP.pp(self, ""))
        now = Time.at(Time.now.getutc)
        self['locked_at'] = nil
        self['finished_at'] = now
        self['expires_at'] = nil
        self['updated_at'] = now
        self['status'] = status
        save!
    end

    # Creates an unlocked process entry in the database of the specified name
    # Not that it matters, but returns false if the row couldn't be created
    # We assume failure to create means a row with that process_name already exists
    def self.createIfNotExists(process_name)
        Processor.new(:process_name => process_name,
                      :locked_at => nil,
                      :started_at => nil,
                      :finished_at => nil,
                      :expires_at => nil,
                      :updated_at => Time.now).save
    end
end
