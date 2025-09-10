class DropTablesPictureInPicturesAndGreenDots < ActiveRecord::Migration[5.1]
  def change
    drop_table :green_dots
    drop_table :picture_in_pictures
  end
end
