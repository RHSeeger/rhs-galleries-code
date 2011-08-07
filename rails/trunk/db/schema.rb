# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "galleries", :force => true do |t|
    t.string   "source"
    t.string   "search"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "flickrPhotoId"
    t.string   "flickrServer"
    t.string   "flickrFarm"
    t.string   "flickrSecret"
    t.string   "flickrOwnerId"
    t.text     "caption"
    t.text     "title"
    t.text     "description"
    t.string   "user"
    t.integer  "gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "processors", :force => true do |t|
    t.string   "process_name"
    t.datetime "locked_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "status"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "processors", ["process_name"], :name => "process_name_index", :unique => true

  create_table "topics", :force => true do |t|
    t.string   "source"
    t.text     "topics"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
