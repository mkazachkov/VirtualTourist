# VirtualTourist

VirtualTourist is the app that can help you create photo album for any interesting place in the world.

# Features
* **Drop new pin.** Create a pin for specific location on the map using long press on the map.
* **Open the photo album.** Photo album for the pin is opened by click. If photo album for the pin doesn't exist the new one is created loading geocoded photos from Flickr.
* **Create new photo album.**  You can re-create the photo album clicking "New Collection" Button. New set of pictures will be loaded.
* **Keep photo album on device.** After creation the photo album is persisted on the device and is available without internet connection.

# Frameworks and External APIs
Random photos are loaded from [Flickr API](https://www.flickr.com/services/api/) by geo coordinates.
Photo albums are persisted on the device using Core Data.

# Installation
The app is not intended to use as a library, so clone, build and run normally using Xcode 11 and Swift 5 :-)
