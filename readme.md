# MultipartBody
The multipart body is an attempt to bring consistency to multipart content in Ruby. When developing CloudMailin we struggled to find a gem to help us create multipart bodies. Many different libraries had implemented multipart bodies through their own implementation but non could be used independently.

The aim of MultipartBody is to ensure consistency when creating (and parsing in future) multipart content

## Usage

    require 'multipart_body'

    # From a hash
    multipart = MultipartBody.new(:field1 => 'content', :field2 => 'something else')

    # With parts
    part = Part.new(:name => 'name', :body => 'body', :filename => 'f.txt', :content_type => 'text/plain', :encoding => :base64)
    
    # or to specify just the name, body and optional filename
    part = Part.new('name', 'content', 'file.txt')
    multipart = MultipartBody.new([part])

    # Output
    part.to_s #=> The part with headers and content
    multipart.to_s #=> The full list of parts joined by boundaries

## TODO
  * Implement Parsing
  * Add different encodings
  * Add the ability to automatically add files and have the filename set

## License
Copyright 2010 by Steve Smith ([CloudMailin](http://cloudmailin.com)) and is released under the MIT license.