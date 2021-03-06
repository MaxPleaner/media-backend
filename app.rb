require 'securerandom'
require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'sqlite3'
require 'pry'
require 'json'
require 'dotenv'

Dotenv.load

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

set :bind, '0.0.0.0'
before do
    env['PATH_INFO'].sub!(/^\/media-backend/, '')
end

TOKEN = ENV["MEDIA_BACKEND_TOKEN"]
raise(ArgumentError, "MEDIA_BACKEND_TOKEN not set") unless TOKEN

def can_authenticate?(given_token)
  TOKEN == given_token
end

before '/*' do
  headers 'Access-Control-Allow-Origin' => 'http://li1196-141.members.linode.com'
  headers 'Accept-Ranges' => 'bytes'
end

AudioResourceHost = "https://li1196-141.members.linode.com/media-backend"
TokenQueryParam = "media_backend_token=#{TOKEN}"

def cache_buster
  "cb=#{SecureRandom.urlsafe_base64}"
end

post '/rtc_audio_upload' do
 return "unauthenticated" unless can_authenticate?(params[:media_backend_token])
  filename = params["fname"]
  data = params["data"] || {}
  file = data[:tempfile]
  path = "public/wav/#{filename}"
  File.open(path, 'w') do |f|
    f.write(file.read)
  end
  public_path = "#{AudioResourceHost}/wav/#{filename}?#{TokenQueryParam}&#{cache_buster}"
  FileRef.create(name: filename, public_path: filename, true_path: path)
  content_type :json
  { url: public_path }.to_json
end

get "/audio_index" do
  content_type :json
  Dir.glob("public/wav/*").map do |path|
    resource_path = path.split("public/")[-1]
    name = resource_path.split("/")[-1]
    { name: name, url: "#{AudioResourceHost}/#{resource_path}?#{TokenQueryParam}&#{cache_buster}" }
  end.to_json
end

get "*" do
  return "unauthenticated" unless can_authenticate?(params[:media_backend_token])
  return "no file path" unless request.path.length > 1
  case request.path.split(".")[-1]
  when "wav"
    content_type 'audio/wav'
  end
  if Dir.glob("public/**/*").include?("public#{request.path}")
#    status 206
    File.read(File.join("public", request.path))
  else
    status 422
    "can't access that file"
  end
end

delete '/delete_audio' do
  return "unauthenticated" unless can_authenticate?(params[:media_backend_token])
  name = params[:name].gsub(/[^0-9A-Za-z.\-]/, '_')
  matching_file = Dir.glob("public/wav/*").first do |path|
    path.split("/")[-1].split(".")[0] == name
  end
  return "cant find audio with that name" unless matching_file
  `rm #{matching_file}`
  return "OK"
end

put '/trim_audio' do
  return "unauthenticated" unless can_authenticate?(params[:media_backend_token])
  name = params[:name].gsub(/[^0-9A-Za-z.\-]/, '_')   
  matching_file = Dir.glob("public/wav/*").first do |path|
    path.split("/")[-1].split(".")[0] == name
  end
  public_path = matching_file.split("public/")[-1]
  return "cant find audio with that name" unless matching_file
  start_time = params[:startTime]
  end_time = params[:endTime]
  duration = end_time.to_f - start_time.to_f
  temp_path = "tmp/#{SecureRandom.urlsafe_base64}.wav"
  `ffmpeg -ss #{start_time} -t #{duration} -i #{matching_file} #{temp_path}`
  `rm #{matching_file}`
  `cp #{temp_path} #{matching_file}`
  `rm #{temp_path}`
  content_type :json
  url = "#{AudioResourceHost}/#{public_path}?#{TokenQueryParam}&#{cache_buster}"
  { url: url }.to_json
end
