class Part < Struct.new(:name, :body, :filename, :content_type, :encoding)
  def initialize(*args)
    if args.flatten.first.is_a? Hash
      from_hash(args.flatten.first)
    elsif args.length > 0
      from_args(*args)
    end
  end
  
  def from_hash(hash)
    hash.each_pair do |k, v|
      self[k] = v
    end
  end
  
  def from_args(name, body, filename=nil)
    self[:name] = name
    self[:body] = body
    self[:filename] = filename
  end
  
  def header
    header = "Content-Disposition: form-data; name=\"#{name}\""
    header << "; filename=\"#{filename}\"" if filename
    header << "\r\nContent-Type: #{content_type}" if content_type
    header << "\r\nContent-Transfer-Encoding: #{encoding}" if encoding
    header
  end
  
  # TODO: Implement encodings
  def encoded_body
    case encoding
    when nil
      body
    else
      raise "Encodings have not been implemented"
    end
  end
  
  def to_s
    "#{header}\r\n\r\n#{encoded_body}"
  end
end