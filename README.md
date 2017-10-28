# MultiColorBlock


MultiColorBlock library is used to recognize the priority of daily task with simple color code.

## Features

- [x] Custom colors
- [x] Custom view size
- [x] Protocol Delegate support

## Demo


## Installation

**MultiColorBlock** is available through [CocoaPods](http://cocoapods.org)

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate MultiColorBlock into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod 'MultiColorBlock'
end
```

Then, run the following command:

```bash
$ pod install
```

Alternatively to give it a test run, run the command:

```bash
$ pod try MultiColorBlock
```

## Requirements

- iOS 9.0+
- Xcode 9.0.0 +

## Basic Usage

To get started, this is a simple usage sample of using the integrated view controller.

```swift
import MultiColorBlock

@IBAction func colorBtnTapped(_ sender: UIButton) {
    //Display color block view on tap button
    let blockView = self.view.showColorBlockView(onTap: sender, with: 100)
    blockView.delegate = self
    //To set custom color
    blockView.setCustomColor(to: .down, color: .green)
    blockView.setCustomColor(to: .right, color: .blue)
    blockView.setCustomColor(to: .up, color: .yellow)
    blockView.setCustomColor(to: .left, color: .red)
}
```
Protocol Delegate methods:
```
func colorBlockDidSelect(color: UIColor) {
    print("color: \(color)")
}

func colorBlockDidClose() {
    print("close")
}
```
For more usage examples check the [Example](/Example) folder.


## Author

nfasate, nfasate@github.com

## License

MultiColorBlock is available under the MIT license. See the LICENSE file for more info.
