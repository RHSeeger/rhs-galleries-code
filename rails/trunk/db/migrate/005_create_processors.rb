class CreateProcessors < ActiveRecord::Migration
    def self.up
        create_table :processors do |t|
            t.string   :process_name   # name of this process
            t.datetime :locked_at      # Set when a client is working on this object, nil when not locked
            t.datetime :started_at     # When this process was started, same as locked_at when process is running
            t.datetime :finished_at    # When this process finished running (or nil if it is currently running)
            t.string   :status
            t.datetime :expires_at     # When this process is considered having run to long
            t.timestamps
        end

        add_index(:processors, [:process_name], :name => 'process_name_index', :unique => true)
    end

    def self.down
        drop_table :processors
    end
end
