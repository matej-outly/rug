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

- `layout` - Layout of rendered table. Possible values are `:table` (default, standard table), `:thumbnails` (grid layout with thumbnails) and `:list` (custom HTML markup)
- `thumbnails_grid` (integer) - Number of columns in the grid (default 3). This option is valid only for `:thumbnails` layout.
- `thumbnails_tiles` (boolean) - Whether to use tile resizer to scale rendered items. This option is valid only for `:thumbnails` layout.
- `thumbnails_crop` (integer) - Crop thumbnails to fixed height. This option is valid only for `:thumbnails` layout.
- `table_format` - Format of rendered table. Possible values are `:table` (default, standard `table` HTML markup) and `:div` (rendered with `div` HTML markup). This option is valid only for `:table` layout.
- `partial` (boolean) - Render onlt partial HTML (see chapter below).

As objects can be passed ActiveRecord::Relation, Array or single ActiveRecord::Base object (automaticaly converted to array).

## List layout

List layout provides a possibility to render each item in custom HTML markup. However, there are some specifics you must be aware. Here is an example rendering items as 3 column grid of (Bootstrap) panels:

```erb
<%= rug_index(objects,
    layout: :list, 
    list_class: "row", 
    item_class: "col-sm-4"
) do |t| %>
    <%= t.header do |h| %>
        <%= h.action :new, path: :new_sample_path %>
    <% end %>
    <%= t.body do |b, sample| %>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><%= sample.name %></h4>
                <div class="actions">
                    <%= b.action :edit, object: sample, label: false, path: :edit_sample_path
                    <%= b.action :destroy, object: sample, label: false, path: :sample_path %>
                </div>
            </div>
            <div class="panel-body">
                <%= sample.description %>
            </div>
        </div>
    <% end %>
<% end %>
```

Notice that you must provide valid `object` option to each call of `action` method. It is also possible to pass `label`, `style`, `size` and other options to modify action button appearence.

In current version of `list` layout, items moving is not implemented.

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

Index builder can be used as core component for creating and updating records over AJAX (without visible HTTP request). Anyway the entire setup is more complicated. Let's say that we work with `index` action on `SamplesController` and `Sample` model.

### View

First, decompose your `index` view to `views/samples/index.html.erb` and `views/samples/_index.html.erb` and `views/samples/_form.html.erb` partials:

#### Main index view template

```erb
<%= render partial: "index", locals: { 
    objects: @samples, 
    options: { 
        reload_path: lambda { |id| samples_path(id: id) } 
    } 
} %>
```

It is also important to provide `reload_path` to the Index builder. Otherwise AJAX reloading is deactivated in JavaScript. Reload path should point to this action and understand ID parameter.

#### Index partial

```erb
<%= rug_index(objects, options) do |t| %>
    <%= t.header do |h| %>
        <%= h.action :new, modal: true do |m| %>
            <%= m.header "New sample" %>
            <%= render partial: "form", locals: { table: t, modal: m, object: Sample.new } %>
        <% end %>
    <% end %>
    <%= t.body do |b| %>
        <%= b.string :name %>
        <%= b.action :edit, modal: true do |m, sample| %>
            <%= m.header "Edit sample" %>
            <%= render partial: "form", locals: { table: t, modal: m, object: sample } %>
        <% end %>
        <%= b.action :destroy, path: :commodity_path, ajax: true %>
    <% end %>
    <%= t.footer do |f| %>
        <%= f.pagination %>
        <%= f.summary %>
    <% end %>
<% end %>
```

It is important to use index partial which contains only Index builder. It is used by main index vie template and alco by controller in case of AJAX load. 

#### Form partial

```erb
<%= rug_form_for(object, 
    create_path: :samples_path, 
    update_path: :sample_path,
    ajax: {
        success_message: Sample.human_notice_message(object.new_record? ? :create : :update),
        error_message: Sample.human_error_message(object.new_record? ? :create : :update),
        clear_on_submit: object.new_record?,
        on_success: {
            toggle_modal: { selector: "##{modal.id}" },
            reload_object: { name: table.js_object }
        }
    }
) do |f| %>
    <%= modal.body do %>
        <%= f.text_input_row :name %>
    <% end %>
    <%= modal.footer do %>
        <%= f.primary_button_row :submit %>
    <% end %>
<% end %>
```

### Controller

Second, prepare your controller to understand provided reload path and connect it to prepared index partial:

```ruby
class SamplesController < ApplicationController
    def index
        @samples = Sample.id(params[:id]).order(name: :asc).page(params[:page])
        respond_to do |format|
            format.html { render "index" }
            format.json do
                render json: @samples.map { |sample|
                    {
                        id: sample.id,
                        html: render_to_string(
                            partial: "index", 
                            formats: [:html], 
                            locals: { 
                                objects: sample, 
                                options: { partial: true } 
                            }
                        )
                    }
                }
            end
        end
    end
end
```

In the JSON responder there is important to pass `partial` option to the Index builder. Otherwise there will be incorrect HTML code rendered to the response.

You must provide create, update and destroy actions also. Each action must respond to JSON with object `id` in case of success and `errors` in case of error.
