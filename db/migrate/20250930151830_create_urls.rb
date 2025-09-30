class CreateUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :urls do |t|
      t.text :long_url
      t.string :short_code

      t.timestamps
    end
    add_index :urls, :short_code, unique: true
  end
end
