require File.join(File.dirname(__FILE__), 'test_helper')
require 'tempfile'

class MultipartBodyTest < Test::Unit::TestCase
  context "MultipartBody" do
    setup do
      @hash = {:test => 'test', :two => 'two'}
      @parts = [Part.new('name', 'value'), Part.new('name2', 'value2')]
      @example_text = "------multipart-boundary-307380\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nvalue\r\n------multipart-boundary-307380\r\nContent-Disposition: form-data; name=\"name2\"\r\n\r\nvalue2\r\n------multipart-boundary-307380--"
    end
    
    should "return a new multipart when sent #from_hash" do
      multipart = MultipartBody.from_hash(@hash)
      assert_equal MultipartBody, multipart.class
    end
    
    should "create a list of parts from the hash when sent #from_hash" do
      multipart = MultipartBody.from_hash(@hash)
      assert_equal @hash, Hash[multipart.parts.map{|part| [part.name, part.body] }]
    end
    
    should "add to the list of parts when sent #new with a hash" do
      multipart = MultipartBody.new(@hash)
      assert_equal @hash, Hash[multipart.parts.map{|part| [part.name, part.body] }]
    end
    
    should "correctly add parts sent #new with parts" do
      multipart = MultipartBody.new(@parts)
      assert_same_elements @parts, multipart.parts
    end
    
    should "assign a boundary if it is not given" do
      multpart = MultipartBody.new()
      assert_match /[\w\d-]{10,}/, multpart.boundary
    end
    
    should "use the boundary provided if given" do
      multipart = MultipartBody.new(nil, "my-boundary")
      assert_equal "my-boundary", multipart.boundary
    end
    
    should "starts with a boundary when sent #to_s" do
      multipart = MultipartBody.new(@parts)
      assert_match /^--#{multipart.boundary}/i, multipart.to_s
    end
    
    should "end with a boundary when sent #to_s" do
      multipart = MultipartBody.new(@parts)
      assert_match /--#{multipart.boundary}--\z/i, multipart.to_s
    end
    
    should "contain the parts joined by a boundary when sent #to_s" do
      multipart = MultipartBody.new(@parts)
      assert_match multipart.parts.join("\r\n--#{multipart.boundary}\r\n"), multipart.to_s
    end
    
    should "contrsuct a valid multipart text when passed #to_s" do
      multipart = MultipartBody.new(@parts)
      multipart.boundary = '----multipart-boundary-307380'
      assert_equal @example_text, multipart.to_s
    end
  end
  
  context "a Part" do
    setup do
      @part = Part
      @file = Tempfile.new('file')
      @file.write('hello')
      @file.flush
      @file.open
    end
    
    should "assign values when sent #new with a hash" do
      part = Part.new(:name => 'test', :body => 'content', :filename => 'name')
      assert_equal 'test', part.name
      assert_equal 'content', part.body
      assert_equal 'name', part.filename
    end
    
    should "assign values when sent #new with values" do
      part = Part.new('test', 'content', 'name')
      assert_equal 'test', part.name
      assert_equal 'content', part.body
      assert_equal 'name', part.filename
    end
    
    should "be happy when sent #new with args without a filename" do
      part = Part.new('test', 'content')
      assert_equal 'test', part.name
      assert_equal 'content', part.body
      assert_equal nil, part.filename
    end
    
    should "create an empty part when sent #new with nothing" do
      part = Part.new()
      assert_equal nil, part.name
      assert_equal nil, part.body
      assert_equal nil, part.filename
    end
    
    should "include a content type when one is set" do
      part = Part.new(:content_type => 'plain/text', :body => 'content')
      assert_match "Content-Type: plain\/text\r\n", part.header
    end
    
    should "include a content disposition when sent #header and one is set" do
      part = Part.new(:content_disposition => 'content-dispo', :body => 'content')
      assert_match "Content-Disposition: content-dispo\r\n", part.header
    end
    
    should "not include a content disposition of form-data when nothing is set" do
      part = Part.new(:body => 'content')
      assert_no_match /content-disposition/i, part.header
    end
    
    should "include a content disposition when sent #header and name is set" do
      part = Part.new(:name => 'key', :body => 'content')
      assert_match /content-disposition: form-data; name="key"/i, part.header
    end
    
    should "include no filename when sent #header and a filename is not set" do
      part = Part.new(:name => 'key', :body => 'content')
      assert_no_match /content-disposition: .+; name=".+"; filename="?.*"?/i, part.header
    end
    
    should "include a filename when sent #header and a filename is set" do
      part = Part.new(:name => 'key', :body => 'content', :filename => 'file.jpg')
      assert_match /content-disposition: .+; name=".+"; filename="file.jpg"/i, part.header
    end
    
    should "return the original body if encoding is not set" do
      part = Part.new(:name => 'key', :body => 'content')
      assert_equal 'content', part.encoded_body
    end
    
    # TODO: Implement encoding tests
    should "raise an exception when an encoding is passed" do
      part = Part.new(:name => 'key', :body => 'content', :encoding => :base64)
      assert_raises RuntimeError do
        part.encoded_body
      end
    end
    
    should "output the header and body when sent #to_s" do
      part = Part.new(:name => 'key', :body => 'content')
      assert_equal "#{part.header}\r\n#{part.body}", part.to_s
    end
    
    should "add the files content not the file when passed a file" do
      part = Part.new(:name => 'key', :body => @file)
      assert_equal 'hello', part.body
    end
    
    should "automatically assign a filename when passed a file to body" do
      part = Part.new(:name => 'key', :body => @file)
      assert_not_nil part.filename
    end
  end
end