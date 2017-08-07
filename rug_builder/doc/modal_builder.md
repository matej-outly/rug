# Modal Builder

Modal builder can be used for rendering modal dialogs. Currently Bootstrap frontend framework is used as output HTML markup.

## Basic usage

Modal dialog can be rendered in the following way:

```erb
<%= rug_modal :sample_modal do |m| %>
    <%= m.header "Sample" %>
    <%= m.body do %>
        ...
    <% end %>
    <%= m.footer do %>
        ...
    <% end %>
<% end %>
```

Button builder has a usefull option integrated to render link or button for modal toggling:

```erb
<%= rug_button "Open sample modal", "#", modal: :sample_modal %>
```

## Usage in combination with form builder

Modal builder can be easily combined with Form builder to render modal containing a form. Form should be rendered with `ajax` option enabled and `behavior_on_submit` option set to `:modal` which causes that modal is closed on form submit:

```erb
<%= rug_modal :new_object_modal do |m| %>
    <%= m.header "Create object" %>
    <%= rug_form_for(Object.new, url: main_app.new_object_path, ajax: {
        success_message: "Object created.",
        error_message: "Object not created.",
        clear_on_submit: true,
        behavior_on_submit: :modal
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
