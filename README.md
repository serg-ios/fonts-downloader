# Fonts Downloader

With this framework you can download a font file, convert it to UIFont and use it in your projects. So you can change the font of your app without releasing a new version.

## Framework

> Under `FontsDownloader` directory.

Among its utilities, you can find:
 
* `Data` to `UIFont` conversion (**.ttf**, **.otf** and **.ttc** formats were tested).
* Cache font data with `FileManager` (all fonts will be cached in a folder called **FontsDownloader** under caches directory).
* Clean the cache, removing all downloaded fonts.

## Tests

> Under `FontsDownloaderTests` directory.

Most of the framework's functionalities have been tested.

Three font files are included for testing purposes (MuktaMahee.ttc, NewYork.ttf, SF-Pro-Text-Regular.otf), all three are available in macOS system fonts.

## Example project

> Under `FontsDownloaderExample` directory.

A simple app that downloads fonts and uses them to change the font of an `UILabel`.

