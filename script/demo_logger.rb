require "rubygems"
require "logger"
require "json"
require "faker"
require "uri"

FILE_PATH = "/tmp/fluent-plugin-nested-hash-filter.demo.log"
@count = 0

def main
  loop do
    object = generate
    output object
    sleep 0.1
    @count += 1
  end
end

def generate
  case @count % 100
  when 0..85
    session_id = @count
  when 86..95
    session_id = ""
  when 96..98
    session_id = @count.to_s.rjust 10, "0"
  else
    session_id = Faker::Lorem.characters 20
  end

  case @count % 100
  when 0..98
    access = Time.now.to_s
    number = Faker::Number.number 10
  else
    access = "undefined"
    number = ""
  end

  uri = URI.parse Faker::Internet.url
  expired = Time.now + ( 3 * 60 * 60 * 24 )
  adsid = Faker::Number.number 8

  {
    session_id: session_id,
    session:    {
      expired: expired,
      ads:     {
        _id:  adsid,
        list: Faker::Lorem.words,
      }
    }.to_json,
    count:      number,
    access:     access,
    uri:        uri.path,
    query: {
      keyword:  Faker::Lorem.words,
      page:     0
    },
    response:   Faker::Lorem.sentence,
    email:      Faker::Internet.safe_email
  }
end

def output object
  File.open FILE_PATH, "a" do |file|
    line = object.to_json
    file.puts line
  end
end

main
