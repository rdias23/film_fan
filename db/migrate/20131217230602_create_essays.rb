class CreateEssays < ActiveRecord::Migration
  def change
    create_table :essays do |t|
      t.string :title
      t.text :body
      t.references :movie, index: true

      t.timestamps
    end
  end
end
