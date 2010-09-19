class Part < Struct.new(:name, :body, :filename, :content_disposition, :content_type, :encoding)
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
    self.from_hash(:name => name, :body => body, :filename => filename)
  end
  
  def header
    header = ""
    if content_disposition || name
      header << "Content-Disposition: #{content_disposition || 'form-data'}"
      header << "; name=\"#{name}\"" if name && !content_disposition
      header << "; filename=\"#{filename}\"" if filename && !content_disposition
      header << "\r\n"
    end
    header << "Content-Type: #{content_type}\r\n" if content_type
    header << "Content-Transfer-Encoding: #{encoding}\r\n" if encoding
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
    "#{header}\r\n#{encoded_body}"
  end
end