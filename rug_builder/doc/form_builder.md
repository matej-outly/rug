# Form Builder

This page describes part of Rug Builder module used for generating standardized HTML forms. It is implemented as an extension of vanilla Rails form builder. This architecture ensures that all features provided by vanilla builder are still available in Rug Form Builder.

## Implementations

This builder is currently implemented for:

- Bootstrap framework
- Gumby framework - Obsolete, DO NOT USE!

## Basic usage

Module defines helper `rug_form_for` with similar interface as vanilla Rails form builder:

```erb
<%= rug_form_for(object, options) do |f| %>
    <%= f.text_input_row :name %>
    ...
<% end %>
```

Builder expects instance of ActiveRecord (model) as object. Alternatively you can use model class as object and form automatically instanciate the class to create valid.

## Additional functionality

Form Builder defines several additional functions. Most of them are predefined form inputs combined with matching label and block for rendering validation errors.

## Known bugs and issues
