class CreateBlacklistedTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :blacklisted_tokens do |t|
      t.string :token, null: false
      t.datetime :exp, null: false

      t.timestamps
    end
    add_index :blacklisted_tokens, :token, unique: true
  end
end
