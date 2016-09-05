**This project is imcomplete (a work in progress)**

# media-backend
sinatra backend for storing music files

---

This is the backend component of [musicker](http://github.com/maxpleaner/musicker).

Whereas the front-end records samples using RecordRTC, the back end saves the samples as `wav` files and serves them as static assets. 

----

_setup_

1. clone
2. bundle
3. `cp .env.example .env`
  - Set the `MEDIA_BACKEND_TOKEN` env var to the same value as in musicker/.env
2 `ruby app.rb`

