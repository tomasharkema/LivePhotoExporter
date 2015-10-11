# Regift
Easily convert a video to a GIF on iOS.

[![Version](https://img.shields.io/cocoapods/v/Regift.svg?style=flat)](http://cocoadocs.org/docsets/Regift)
[![License](https://img.shields.io/cocoapods/l/Regift.svg?style=flat)](http://cocoadocs.org/docsets/Regift)
[![Platform](https://img.shields.io/cocoapods/p/Regift.svg?style=flat)](http://cocoadocs.org/docsets/Regift)

## Installation
### Cocoapods

Regift is available through [CocoaPods](http://cocoapods.org), and requires Swift 2. To install
it, simply add the following line to your Podfile:

    pod "Regift"

## Quick Start
```swift
import Regift
```

```swift
let videoURL   = ...
let frameCount = 16
let delayTime  = 0.2
let loopCount  = 0    // 0 means loop forever

let regift = Regift(sourceFileURL: videoURL, frameCount: frameCount, delayTime, loopCount: loopCount)
print("Gif saved to \(regift.createGif())")
```

## Acknowledgements
Thanks to [Rob Mayoff's Gist](https://gist.github.com/mayoff/4969104), without which this library wouldn't exist.
