# Show Builder

New version of show builder. Not implemented yet.

## Basic usage

Show builder can be used in the following way:

```erb
<%= rug_show(object, options) do |t| %>

    <%= t.header do |h| %>
        <%= h.h2 "Object detail" %>
        <%= h.action :edit, path: lambda { |object| main_app.edit_object_path(object, some_param: "foo") %>
        <%= h.action :destroy, path: "main_app.object_path" %>
        <%= h.action :synchronize, label: "Synchronize", icon: "reload", path: "main_app.synchronize_object_path", method: :put %>
    <% end %>

    <%= t.body do |b| %>
        <%= b.string :name %>
        <%= b.row do |r| %>
            <%= r.col(6) do |c| %>
                <%= c.datetime :created_at, label: "Created" %>
            <%= end %>
            <%= r.col(6) do |c| %>
                <%= c.datetime :updated_at, label: "Updated" %>
            <%= end %>
        <% end %>
        <%= b.h3 "Description" %>
        <%= b.text :description, truncate: false, label: false %>
        <%= b.custom :name_and_email, label: "Name and email" do |object| %>
            <%= object.name %> ( <%= object.email %> )
        <% end %>
    <% end %>

    <%= t.footer do |f| %>
        <%= f.action :new, path: "main_app.new_object_path" %>
    <% end %>

<% end %>
```

Available options:

- `show_blank_rows` - turn on rows without any content

## AJAX reload


