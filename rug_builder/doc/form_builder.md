# Form Builder

Form builder can be used for generating standardized HTML forms. It is implemented as an extension of vanilla Rails form builder. This architecture ensures that all features provided by vanilla builder are still available in Form builder. Currently Bootstrap frontend framework is used as output HTML markup.

## Basic usage

Module defines helper `rug_form_for` with similar interface as vanilla Rails form builder:

```erb
<%= rug_form_for(object, options) do |f| %>
    <%= f.text_input_row :name %>
    ...
<% end %>
```

Builder expects instance of ActiveRecord (model) as object. Alternatively you can use model class as object and form automatically instanciate the class to create valid behavior.

## Additional functionality

Form Builder defines several additional functions. Most of them are predefined form inputs combined with label and block with validation errors. Those functions are suffixed with `_row`. Some of the available input builders correspond to additional data types defined by Rug Record module. 

### Buttons

`primary_button_row` creates standard button designed for form submitting. Based on `new_record?` attribute it responds to object instance and uses different default label for newly created objects (new actions) and objects already saved in DB (edit action). Based on used frontend framework it styles button to `primary` style.

```erb
<%= f.primary_button_row :submit %>
<%= f.primary_button_row :submit, label: "My custom label", style: "secondary", class: "my-submit-button" %>
```

Available options:

- `label` - custom button label
- `style` - to set different button style than default `primary`
- `class` - additional CSS class

---

`button_row` creates common button used as link. Based on used frontend framework it styles button to `default` style. It expects URL to where user should be redirected when he clicks on the button.

```erb
<%= f.button_row "My label", my_action_path %>
<%= f.button_row "My label", my_action_path, style: "secondary", class: "my-button" %>
```

Available options:

- `style` - to set different button style than default `primary`
- `class` - additional CSS class

---

`link_button_row` is similar to `button_row` but default style is set to `link` and can't be overriden in options.

```erb
<%= f.link_button_row "My label", my_action_path %>
<%= f.link_button_row "My label", my_action_path, class: "my-button" %>
```

Available options:

- `class` - additional CSS class

---

`back_link_button_row` is similar to `link_button_row` but URL is always set to `request.referrer` and label is automatically set.

```erb
<%= f.back_link_button_row %>
<%= f.link_button_row class: "my-button" %>
```

Available options:

- `class` - additional CSS class

### Checkboxes

`checkboxes_row`

Available options:

- `label`
- `enable_bootstrap`

---

`checkbox_row`

Available options:

- `label`
- `enable_bootstrap`

### Date / Time

`date_picker_row`

Available options:

- options similar to `text_input_row`

---

`time_picker_row`

Available options:

- options similar to `text_input_row`

---

`datetime_picker_row`

Available options:

- `label`
- `label_date`
- `label_time`
- `class`

---

`datetime_range_picker_row`

Available options:

- `label`
- `label_date_from`
- `label_date_to`
- `label_time_from`
- `label_time_to`
- `class`
- `date_from`
- `date_to`
- `time_from`
- `time_to`

---

`duration_picker_row`

Available options:

- `label`
- `label_days`
- `label_hours`
- `label_minutes`
- `label_seconds`
- `class`
- `days`
- `hours`
- `minutes`
- `seconds`

### Dropzone

`dropzone_row`

Available options:

- `label`
- `create_path`
- `update_path`
- `reload_object`
- `append_columns`

---

`dropzone_many_row`

Available options:

- `label`
- `attachment_name`
- `create_path`
- `destroy_path`
- `reload_object`
- `append_columns`
- `collection`
- `collection_class`

## Ajax form



## Known bugs and issues
