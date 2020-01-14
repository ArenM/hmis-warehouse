# This migration comes from letsencrypt_plugin (originally 20151206135029)
class CreateLetsencryptPluginChallenges < ActiveRecord::Migration[4.2][4.2]
  def change
    return if ActiveRecord::Base.connection.table_exists? :letsencrypt_plugin_challenges
    create_table :letsencrypt_plugin_challenges do |t|
      t.text :response

      t.timestamps null: false
    end
  end
end
