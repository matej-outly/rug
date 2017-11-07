# Importer

Importer is a library designed to help with complex and time consuming data import into the local database. Based on this library you can design a custom importer which implements specific algorithm for conversion between input data structure and local database. There are several key features already integrated into the library and ready to be used:

- Support for different input data format, such as XML, TXT, MySQL or PostgreSQL database.
- Support for different compression and packaging of input data, such as ZIP or GZIP.
- Support for both remote (HTTP and FTP) and local (local file) sources.
- Helper parse functions, such as parsing elements and attributes from XML and loading rows from TXT file.
- Memory optimization for XML parsing.
- QueueClassic enqueuing.
- Support for batches.
- Exceptions hiding to correctly work with QueueClassic background jobs. 
- Simplified logging which hides standard Rails SQL logs.
- Simple tasks counting for displaying progress
- Import status logging into the database.

## Basic usage

You can create your importer by extending `RugRecord::Importer` class and defining tour import tasks:

```ruby
class SampleImporter < RugRecord::Importer
    
    # Settings
    set_driver :xml

    # Task
    def_import_url :samples, "http://www.domail.com/export/samples.xml"
    def_import_block :samples do |options|
        xml_load(options[:url]) do |samples_element|
            # samples_element (root) is a Nokogiri object with entirely parsed XML document probably containing many SAMPLE elements...
        end
    end

end
```

Now you can run the importer with this piece of code:

```ruby
SampleImporter.import
```

## Data source

### Import from database

### Import from remote URL or local file

In case you don't use database as data source, you have to define URL where to find your input data. According to URL protocol importer automatically decides how to download the source file:

- URLs starting with "http://" or "https://" will be managed as HTTP links and loaded with rest client.
- URLs starting with "ftp://" will be managed as FTP and will be loaded with FTP client.
- URLs starting with "file://" will be managed as files in the local file system and will be loaded directly through OS API.

## Custom import blocks

## XML import

### Optimized XML loading

In many cased XML file can be very big and parsing the entire file into the memory (with Nokogiri) is impossible (not enough resources on server). In these cases, there is usually a lot of recurring XML elements with similar structure representing rows in a really big DB table. It's very appropriate to split the XML into the parts and parse only one row in one moment:

```ruby
xml_load(options[:url], split_by_element: "sample") do |sample_element|
    # sample_element is a Nokogiri object representing single SAMPLE element ...
end
```

In this case, block will be called multiple times for each SAMPLE element found in the document. After each iteration memory is completely freed to eliminate resource exhaustion

### XML parsing

You can use several helper methods to parse XML element (represented by Nokogiri object):

- `xml_inner_text(element)` - Return text contained inside the element.
- `xml_attr(element, attr_name)` - Return value of attribute defined on the element.

If we consider XML to look like this:

```xml
<samples>
    <sample id="1">
        <description flag="new">
            <title>Title 1</title>
            <perex>Lorem ipsum dolor sit amet/perex>
        </description>
        <photos>
            <photo>http://...photo_1.jpg</photo>
            <photo>http://...photo_2.jpg</photo>
            <photo>http://...photo_3.jpg</photo>
        </photos>
    </sample>
    <sample id="2">
        ...
    </sample>
</samples>
```

Standard skeleton of XML parsing will be something like this:

```ruby
xml_load(options[:url], split_by_element: "sample") do |sample_element|
    id = xml_attr(sample_element, "id")
    description_element = sample_element.css("description").first
    if description_element
        title = xml_inner_text(description_element.css("title").first)
        perex = xml_inner_text(description_element.css("perex").first)
        flag = xml_attr(description_element, "flag")
    end
    sample_element.css("photos > photo").each do |photo_element|
        photo_urls << xml_inner_text(photo_element)
    end
end
```

## Other features

### Exception hiding

By default all exceptions raised in import tasks are caught and printed as simple message into the logger. They can be also notified into the subject as error message. This behavior is designed for running in background jobs where raised exception would be a big problem (it would block job runner and possible cripple other background jobs). Anyway, for testing it is often good not to catch the exception and print backtrace instead. For this resn it's recommended to activate exceptions in development environment:

```ruby
class SampleImporter < RugRecord::Importer
    if Rails.env.development?
        set_exceptions :raise
    end

    ...
end
```

### Progress logging

You can log progress with the following methods:

```ruby
init_progress(all_data_rows.count, "samples")
all_data_rows.each do |data_row|
    ...
    increment_progress
end
finish_progress
```

Or if you don't know rows count:

```ruby
init_progress(nil, "samples")
while !finished do
    ...
    tick_progress # or increment_progress - output is similar
end
finish_progress
```

Functions `init_progress` and `finish_progress` are automatically called if you use `def_import_block` so it's not necessary to call them maually. If you use `def_import_custom_block` instead, you should manage `init_progress` and `finish_progress` methods by yourself.
