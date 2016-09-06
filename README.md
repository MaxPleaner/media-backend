# Note this is incomplete (a work in progress)

This is the backend component of [musicker](http://github.com/maxpleaner/musicker), a website for making music by recording and looping samples.

This is relatively simple Sinatra app; mostly everything here is in [app.rb](./app.rb)

---

**_Setup_**

1. clone
2. bundle
3. `cp .env.example .env`
  - make the `MEDIA_BACKEND_TOKEN` value match `musicker/.env`
4. Make sure this app is being served over HTTPS
5. `ruby app.rb`

**_Usage/Routes_**

1. `post '/rtc_audio_upload'`
  - save an audio file which was recorded in the browser

2. `get "/audio_index"`
  - get a list of all the saved audio files

3. `get "*"`
  - basically works like a static server, but will serve .wav files with the correct Content-Type

4. `delete '/delete_audio'`
  - deletes an audio file



