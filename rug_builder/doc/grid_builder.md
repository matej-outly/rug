# Grid Builder

Grid builder can be used for grid layout rendering. Currently Bootstrap frontend framework is used as output HTML markup.

## Basic usage

Grid can be rendered in the following way:

```erb
<%= rug_grid do |g| %>
    <%= g.row do |r| %>
        <%= r.col(6) do |c| %>
            ...
        <% end %>
        <%= r.col(6) do |c| %>
            ...
        <% end %>
    <% end %>
    <%= g.row do |r| %>
        <%= r.col(4) do |c| %>
            ...
        <% end %>
        <%= r.col(8) do |c| %>
            ...
        <% end %>
    <% end %>
<% end %>
```
