# Poképing

A small proof-of-concept app I made for a talk about RxSwift and CouchbaseLite. It was also a fun playground to learn ReactiveX.

It's made to show a few different scenarios using ReactiveX, sometimes in relationship with a Couchbase instance using both regular queries and livequeries.

The main feature is fetching Pings from a remote database through Sync Gateway (located inside the `SyncGateway` folder) and adding pings through the "+" button on the main interface (search pokémons only with their french names is supported right now).

I'm looking for feedback from the RxSwift community for improvements on the small scope of this app.

This version works with Xcode 8 beta 6 and has not been tested on other versions.