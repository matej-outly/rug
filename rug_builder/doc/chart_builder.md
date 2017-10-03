# Chart Builder

Chart builder can be used for rendering different kinds of charts. It's based on Chartkick library. This library supports a lot of basic charts which can be used instantly. Check the official website: https://www.chartkick.com/. Chartkick can be used with different charting engines like Google Charts, Chart.js or Highcharts. This documentation uses Google Charts engine, but it's very simple to switch the engine, just follow instructions in chartkick documentation.

It's very convinient to use Groupdate library for grouping temporal data. You can find documentation on https://github.com/ankane/groupdate.

Chart builder adds some more complex charts like "time flexible" line or area chart.

## Instalation and configuration

Add this lines to your application's Gemfile:

```ruby
gem "chartkick"
gem "groupdate"
```

And then execute:

    $ bundle install

And include Chartkick JavaScript into your asset pipeline (`application.js`):

    //= require chartkick

`RugChart` JavaScript library must be included in the asset pipeline if you want to use time flexible charts. Anyway, if you use `RuthApplication` or `RuthAdmin` theme, this library is already included:

    //= require rug_builder/rug_chart 

## Basic usage

Basic charts can be rendered in the following way:

```erb
```

## Time flexible charts

User can choose a date range to examine. Time flexible charts adapts to the selected date range and display data in a convinient grouping (by days, weeks, months, years, ...). For this functionality you must provide backend action which serves the data in correct form:

```ruby
```

When backend function is prepared, you can render the chart in the following way:

```erb
```

