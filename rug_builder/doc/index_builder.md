# Index Builder

New version of index builder. Not implemented yet.

## Basic usage

Index builder can be used in the following way:

```erb
<%= rug_index(objects, options) do |t| %>

    <%= t.header do |h| %>
        <%= h.h2 "Objects" %>
        <%= h.action :new, modal: true do |m| %>
            <%= rug_form_for(Object.new, url: main_app.new_object_path, ajax: {
                success_message: "Object created.",
                error_message: "Object not created.",
                clear_on_submit: true,
                move_to_object: t.js_object
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
        <%= h.action :synchronize_all, label: "Synchronize all objects", icon: "reload", path: "main_app.synchronize_objects_path", method: :put %>
    <% end %>

    <%= t.body do |b| %>
        <%= b.action :move, path: "main_app.move_object_path" %>
        <%= b.integer :id, sort: true %>
        <%= b.datetime :created_at, label: "Created", sort: true %>
        <%= b.string :name, show: { if: lambda { |object| object.presentable? } } %>
        <%= b.text :description, label: false %>
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
- `grid` (integer) - Number of columns in the grid (default 3). This option is valid only for `:thumbnails` layout.
crop). This option is valid only for `:thumbnails` layout.
- `tiles` (boolean) - Whether to use tile resizer to caption. This option is valid only for `:thumbnails` layout.
- `format` - Format of rendered table. Possible values are `:table` (default, standard `table` HTML markup) and `:div` (rendered with `div` HTML markup). This option is valid only for `:table` layout.

# AJAX reload and pagination


