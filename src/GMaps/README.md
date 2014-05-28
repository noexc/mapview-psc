# gmaps-purescript

This is a purescript FFI wrapper over the Google Maps v3 Javascript API.

As of right now, it only provides things that we need in MapView, so the API
is very limited, and things that we wrap (such as MapOptions) are missing
optional fields.

The eventual goal is that this becomes a separate project from MapView and
usable on its own for anyone wishing to work with Google Maps.

It is licensed under the MIT license.
