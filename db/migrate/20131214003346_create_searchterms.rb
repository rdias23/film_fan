class CreateSearchterms < ActiveRecord::Migration
  def change
    create_table :searchterms do |t|
      t.string :term
      t.references :user, index: true

      t.timestamps
    end
  end
end
