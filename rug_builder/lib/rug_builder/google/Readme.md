# Google Maps helper

Google Maps helper provides an easy way to integrate Google Maps into your website.

- [Documentation of Google Maps API](https://developers.google.com/maps/documentation/javascript/tutorial).

## Obtain Google Maps API key

Google Maps is now protected by an API key, which can be easily obtained from [this page](https://developers.google.com/maps/documentation/javascript/get-api-key).

## Use Rug Google Maps builder in templates

To create simple map focused on given point, just include this piece of code into
your template:

```erb
<%= rug_map "gmap", latitude: 50.0596696, longitude: 14.4656239, zoom: 9, api_key: "YOUR_GOOGLE_MAPS_API_KEY", scrollwheel: true %>
```

If you want to display also maker in the center of the map, just add another line of code:

```erb
<%= rug_map "gmap", latitude: 50.0596696, longitude: 14.4656239, zoom: 9, api_key: "YOUR_GOOGLE_MAPS_API_KEY", scrollwheel: true do |m| %>
	<%= m.marker "Roja", lat, lon %>
<% end %>
```
