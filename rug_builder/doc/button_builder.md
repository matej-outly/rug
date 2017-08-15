# Button Builder

Button builder can be used for rendering various buttons and also dropdown buttons. Currently Bootstrap frontend framework is used as output HTML markup.

## Basic usage

Button can be rendered in the following way:

```erb
<%= rug_button "Some label", sample_path, 
    style: :primary, 
    size: :sm, 
    tooltip: "Some tooltip", 
    method: :put, 
    active: true 
%>
```

Options:

- style
- size
- color
- class
- method
- active
- data
- tooltip
- modal
- format

## Dropdown button

Dropdown button can be rendered in the following way:

```erb
<%= rug_dropdown_button "Some label" do |m| %>
    <%= m.item "First label", first_sample_path, method: :put %>
    <%= m.item "Second label", second_sample_path, active: true %>
<% end %>
```