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
        <%= b.datetime :created_at, label: "Created" %>
        <%= b.datetime :updated_at, label: "Updated" %>
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

- `blank_rows` - Turn on rows without any content

## Modal actions

Actions can be used for rendering modal dialogs. This functionality is available in both header and footer. In the following example there is an edit form integrated into the actions modal dialog:

```erb
<%= h.action :edit, modal: true do |m, object| %>
    <%= rug_form_for(object, url: main_app.object_path, ajax: {
        success_message: "Object saved.",
        error_message: "Object not saves.",
        clear_on_submit: false
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

## Complex show dialogs

Show builder can be easily integrated with Grid and Tab builder to create complex show dialogs:

```erb
<%= rug_show(object, options) do |t| %>

    <%= t.header do |h| %>
        ...
    <% end %>

    <%= rug_grid do |g| %>
        <%= g.row do |r| %>
            <%= r.col(6) do |c| %>
                <%= t.body do |b| %>
                    ...
                <% end %>
            <% end %>
            <%= r.col(6) do |c| %>
                <%= t.body context: lambda { |object| object.owner } do |b| %>
                    ...
                <% end %>
             <% end %>
        <% end %>
    <% end %>

    <%= t.footer do |f| %>
       ...
    <% end %>

<% end %>
```

Notice that `body` can be rendered multiple times. You can pass an `context` option (lambda function) to `body` in order to override context (object) in which body is rendered. It can be used for rendering related objects such as owner in the example above.

## AJAX reload


