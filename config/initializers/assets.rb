# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( print.css )
Rails.application.config.assets.precompile += %w( chart.js table_search.js viewable_entities.js )
Rails.application.config.assets.precompile += ['theme/styles/*.css']
Rails.application.config.assets.precompile += %w( moment.min.js )
Rails.application.config.assets.precompile += %w( handsontable.full.min.css )
Rails.application.config.assets.precompile += %w( handsontable.full.js )
Rails.application.config.assets.precompile += %w( ag-grid/ag-grid.min.js )
Rails.application.config.assets.precompile += %w( billboard/billboard.min.css billboard/billboard.min.css billboard/billboard.min.js )
