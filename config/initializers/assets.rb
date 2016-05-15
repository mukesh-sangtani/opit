# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( 
	manager.css
	manager_css/multi-select.css
	manager_css/bootstrap.min.css
	manager_css/pixel-admin.min.css
	manager_css/pages.min.css
	manager_css/style.css
	style.css
	select2.min.css
	jquery.fileupload-noscript.css
	jquery.fileupload-ui-noscript.css
	manager_css/multiple-select.css
	manager.js
	select2.min.js
	manager_js/jquery.multi-select.js
	manager_js/jquery.quicksearch.js
	manager_js/jquery.slimscroll.min.js
	manager_js/jquery-dateFormat.min.js
	manager_js/jquery.min.js
	jquery-fileupload/basic
	manager_js/multiple-select.js
)