# Accordion Builder

Accordion builder can be used for rendering accordion component - a set of collapsable tabs, only one tab can be open at the time.

## Basic usage

Accordion can be rendered in the following way:

```erb
<%= rug_accordion do |a| %>
    <%= a.tab :tab_1 do |t| %>
        <%= t.header "Tab 1 label" do |h| %>
            <div class="actions">
                <%= rug_button(rug_icon(:edit), edit_tab_path) %>
                <%= rug_button(rug_icon(:destroy), tab_path, method: :delete) %>
            </div>
        <% end %>
        <%= t.body do |h| %>
            <p>
                Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
            </p>
        <% end %>
    <% end %>
    <%= a.tab :tab_2 do |t| %>
        <%= t.header "Tab 2 label" %>
        <%= t.body do |h| %>
            <p>
                Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
            </p>
        <% end %>
    <% end %>
<% end %>
```
