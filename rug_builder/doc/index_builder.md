# Index Builder

New version of index builder. Not implemented yet.

## Basic usage

Index builder can be used in the following way:

```erb
<%= rug_index(objects, options) do |t| %>

    <%= t.header do |h| %>
        <%= h.h2 "Objects" %>
        <%= h.action :new, path: main_app.new_object_path %>
        <%= h.action :synchronize_all, label: "Synchronize all objects", icon: "reload", path: "main_app.synchronize_objects_path", method: :put %>
    <% end %>

    <%= t.body do |b| %>
        <%= b.action :move, path: "main_app.move_object_path" %>
        <%= b.integer :id, sort: true %>
        <%= b.datetime :created_at, label: "Created", sort: true %>
        <%= b.string :name, show: { path: "main_app.object_path", if: lambda { |object| object.presentable? } } %>
        <%= b.text :description, type: { strip_tags: true, truncate: true, more: true }, label: false %>
        <%= b.custom :name_and_email, label: "Name and email" do |object| %>
            <%= object.name %> ( <%= object.email %> )
        <% end %>
        <%= b.action :edit, path: lambda { |object| main_app.edit_object_path(object, some_param: "foo") %>
        <%= b.action :destroy, path: "main_app.object_path", inline: true %>
    <% end %>

    <%= t.footer do |f| %>
        <%= f.pagination %>
        <%= f.summary %>
    <% end %>
    
<% end %>
```

Available options:

- `layout` - Layout of rendered table. Possible values are `:table` (default, standard table) and `:thumbnails` (grid layout with thumbnails)
- `thumbnails_grid` (integer) - Number of columns in the grid (default 3). This option is valid only for `:thumbnails` layout.
- `thumbnails_tiles` (boolean) - Whether to use tile resizer to scale rendered items. This option is valid only for `:thumbnails` layout.
- `thumbnails_crop` (integer) - Crop thumbnails to fixed height. This option is valid only for `:thumbnails` layout.
- `table_format` - Format of rendered table. Possible values are `:table` (default, standard `table` HTML markup) and `:div` (rendered with `div` HTML markup). This option is valid only for `:table` layout.
- `partial` (boolean) - Render onlt partial HTML (see chapter below).

As objects can be passed ActiveRecord::Relation, Array or single ActiveRecord::Base object (automaticaly converted to array).

## Modal actions

Actions can be used for rendering modal dialogs. This functionality is available in table header, footer and also in body. In the following example there is a new form integrated into the actions modal dialog in table header:

```erb
<%= h.action :new, modal: true do |m| %>
    <%= rug_form_for(Object.new, url: main_app.objects_path, ajax: {
        success_message: "Object created.",
        error_message: "Object not created.",
        clear_on_submit: true,
        on_success {
            reload_object: { name: t.js_object },
            toggle_modal: { selector: "##{m.id}" }
        }
    }) do |f| %>
        <%= m.body do %>
            <%= f.text_input_row :name %>
            <%= f.text_area_row :description %>
        <% end %>
        <%= m.footer do %>
            <%= f.primary_buton_row :submit %>
        <% end %>
    <% end %>
<% end %>
```

In the following example there is an edit form integrated into the actions modal dialog in table body:

```erb
<%= b.action :edit, modal: true do |m, object| %>
    <%= rug_form_for(object, url: main_app.object_path, ajax: {
        success_message: "Object saved.",
        error_message: "Object not saved.",
        clear_on_submit: false,
        on_success {
            reload_object: { name: t.js_object },
            toggle_modal: { selector: "##{m.id}" }
        }
    }) do |f| %>
        <%= m.body do %>
            <%= f.text_input_row :name %>
            <%= f.text_area_row :description %>
        <% end %>
        <%= m.footer do %>
            <%= f.primary_buton_row :submit %>
        <% end %>
    <% end %>
<% end %>
```

## Partial rendering

If option partial is set to `true`, builder renders only HTML highly coupled with given objects. Header, footer, JS and other wrapping HTMl is skipped. For table layout output looks like:

```html
<tr data-id="1"><td>...</td><td>...</td><td>...</td></tr>
<tr data-id="2"><td>...</td><td>...</td><td>...</td></tr>
...
```

For thumbnails layout output looks like:

```html
<div class="item ..."><div class="thumbnail ...">...</div></div>
```

## AJAX reload

TODO entire concept of render_to_string from controller, partials, etc.
