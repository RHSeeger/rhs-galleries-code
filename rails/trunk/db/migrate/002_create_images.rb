class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :flickrPhotoId
      t.string :flickrServer
      t.string :flickrFarm
      t.string :flickrSecret
      t.string :flickrOwnerId
      t.text :caption
      t.text :title
      t.text :description
      t.string :user

      t.references :gallery

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
