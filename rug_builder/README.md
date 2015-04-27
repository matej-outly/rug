# RugBuilder

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'rug_builder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rug_builder

## Usage

module ApplicationHelper

	def rug_form_for(object, options = {}, &block)
		options[:builder] = RugBuilder::FormBuilder
		form_for(object, options, &block)
	end

	def rug_index_table_for(objects, columns, paths)
		RugBuilder::TableBuilder.new(self).index(objects, columns, paths)
	end

	def rug_show_table_for(object, columns)
		RugBuilder::TableBuilder.new(self).show(object, columns)
	end

	def rug_menu_for(object, options = {}, &block)
		RugBuilder::MenuBuilder.new(self).render(object, options, &block)
	end
	
end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
