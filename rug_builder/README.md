# Rug Builder

This gem provides usefull functions and objects (builders) for producing standardized HTML content. It contains builders for HTML forms, data tables and trees, buttons, icons, labels, tabs, charts, maps and others.

## Installation

Add this line to your application's Gemfile:

    gem 'rug_builder'

And then execute:

    $ bundle install

## Usage

Rug Builder contains of several independent parts. See usage details in designated documentation pages.

This module is aware of different frontend frameworks. We consider Bootstrap framework a standard for creating modern HTML content. However there is a possibility to incorporate different approaches to generate some specific content or completely switch the framework for something even cooler. For example, FontAwesome is pretty great library to render icons and Rug Builder makes it very easy to switch this specific builder to use this library.

Global module configuration is done in config/initializers/rug_builder.rb file:

```ruby
RugBuilder.setup do |config|
	config.frontend_framework = "bootstrap"
	config.icon_framework = "font_awesome"
	config.map_framework = "google"
end
```

Currently, there is possible to set the following values:
- `frontend_framework` option
  - `bootstrap` (default) - Use Bootstrap 3 for rendering.
  - `gumby` - This value is very obsolete and probably not working correctly.
- `icon_framework` option
  - `bootstrap` (default) - Use Bootstrap Glyphicons for icons rendering.
  - `font_awesome` - Use FontAwesome for icons rendering.
- `map_framework` option
  - `google` (default) - Use Google Maps API to render maps.

## Contributing

Send your proposal to matej.outly@clockstar.cz. We will consider and integrate it to the project.
