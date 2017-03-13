# Google Maps helper

Google Maps helper provides an easy way to integrate Google Maps into your website.

- [Documentation of Google Maps API](https://developers.google.com/maps/documentation/javascript/tutorial).

## Obtain Google Maps API key

Google Maps is now protected by an API key, which can be easily obtained from this page:

- [Get API key](https://developers.google.com/maps/documentation/javascript/get-api-key).

## Usage in templates

To create simple map focused on given point and marker displayed in the center of
the map, add these lines into your template:

```erb
<%= rug_map "gmap", latitude: 50.0596696, longitude: 14.4656239, zoom: 9, api_key: "YOUR_GOOGLE_MAPS_API_KEY", scrollwheel: true do |m| %>
	<%= m.marker "Your title", 50.0596696, 14.4656239 %>
<% end %>
```

## Styling

Template helper `rug_map` generates this HTML markup:

```html
<div id="map_23887fb53d507d57b07b5e614f2257749c8dd6f9" class="map">
	<div class="mapbox"></div>
</div>
```

The identifier `map_23887fb53d507d57b07b5e614f2257749c8dd6f9` is unique generated id of the map, which is generated
on every page reload.

Google Map is inserted into `mapbox` element. It is important to *set at least height* of
`mapbox`, like:

```css
.mapbox {
	height: 300px;
}
```

## Known bugs

- Is is not possible to use single line `rug_map` without block
- The `scrollwheel` attribute must be presented