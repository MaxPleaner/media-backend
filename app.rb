require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'sqlite3'
require 'pry'
require 'json'

DataMapper.setup(:default, 'sqlite:backend.db')

class FileRef
  include DataMapper::Resource
  property :id,          Serial
  property :name,        String
  property :public_path, String
  property :true_path,   String
  property :created_at,  DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!


get '/' do
  ""
end

post '/rtc_audio_upload' do
  filename = params["fname"]
  data = params["data"] || {}
  file = data[:tempfile]
  path = "public/#{filename}"
  puts file.class
  File.open(path, 'w') do |f|
    f.write(file.read)
  end
  FileRef.create(name: filename, public_path: filename, true_path: path)
  content_type :json
  headers 'Access-Control-Allow-Origin' => 'http://localhost:4567'
  { path: path }.to_json
end
