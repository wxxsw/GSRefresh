![GSRefresh](https://github.com/wxxsw/GSRefresh/blob/master/ScreenShots/logo.png)

<p align="center">
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift4-f48041.svg?style=flat"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="http://cocoadocs.org/docsets/GSRefresh"><img src="https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/wxxsw/GSRefresh/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat"></a>
<a href="https://github.com/wxxsw/GSRefresh/tree/0.4.2"><img src="https://img.shields.io/badge/release-0.4.2-blue.svg"></a>
</p>

<!--## Demo

![](https://github.com/wxxsw/GSRefresh/blob/master/ScreenShots/demo.gif)-->

## Example

### Refresh

Set the drop-down refresh:
```swift
scrollView.refresh.setup(view: CustomRefreshView) {
	/// do something...
	self.scrollView.refresh.endRefreshing()
}
```

Immediately trigger the refresh state:
```swift
scrollView.refresh.beginRefreshing()
```

End the refresh state:
```swift
scrollView.refresh.endRefreshing()
```

#### Custom Refresh View

```swift
extension SomeView: CustomRefresh {

    /// @optional, default is 44.
    /// Sets the height displayed when refreshing.
    var refreshingKeepHeight: CGFloat { return 44 }
    
    /// @optional, default is .init(top: 30, left: 0, bottom: 0, right: 0).
    /// -top: increase the trigger refresh distance.
    /// -left and right: set the horizontal offset.
    /// -bottom: increase the distance from scrollview.
    var refreshInsets: UIEdgeInsets { return .zero }

    /**
     In this method, set the UI in different states.
     There are three status types: initial, pulling, refreshing.
    
     - parameter previous: previous refresh state
     - parameter newState: new refresh state
    */
    func refreshStateChanged(previous: RefreshState, newState: RefreshState) {
  	    /// do something...
    }
  
}

let someView = SomeView(frame: ...)

scrollView.refresh.setup(view: someView) {
	/// do something...
	self.scrollView.refresh.endRefreshing()
}
```

### LoadMore

Set the pull-up load:
```swift
scrollView.loadMore.setup(view: CustomLoadMoreView) {
	/// do something...
	self.scrollView.loadMore.endRefreshing(noMore: Bool)
}
```

Immediately trigger the refresh state:
```swift
scrollView.loadMore.beginRefreshing()
```

End the refresh state and set whether no longer try to load new data:
```swift
scrollView.loadMore.endRefreshing(noMore: Bool)
```

Reset to continue loading data:
```swift
scrollView.loadMore.reset()
```

No longer try to load new data:
```swift
scrollView.loadMore.noMore()
```

#### Custom LoadMore View

```swift
extension SomeView: CustomLoadMore {

    /// @optional, default is 0.
    /// Set the preload configuration, such as half screen 0.5, one screen is 1, two screens are 2, no preload is 0.
    var preload: CGFloat { get }
    
    /// @optional, default is true.
    /// When there is no more data, is it necessary to keep the height of the custom view? If it is false, it will not be displayed.
    var isVisibleNoMore: Bool { get }
    
    /// @optional, default is .zero.
    /// -top: increase the distance from scrollview.
    /// -left and right: set the horizontal offset.
    /// -bottom: increase the distance from the bottom.
    var loadMoreInsets: UIEdgeInsets { get }
    
    /**
     In this method, set the UI in different states.
     There are three status types: initial, refreshing, noMore.
     
     - parameter previous: previous load more state
     - parameter newState: new load more state
     */
    func loadMoreStateChanged(previous: LoadMoreState, newState: LoadMoreState)
  	    /// do something...
    }
  
}

let someView = SomeView(frame: ...)

scrollView.loadMore.setup(view: someView) {
	/// do something...
	self.scrollView.loadMore.endRefreshing(noMore: Bool)
}
```

## Requirements

### Master

- iOS 8.0+
- Xcode 9.x (Swift 4.x)

### [0.3.0](https://github.com/wxxsw/GSRefresh/tree/0.3.0)

- iOS 8.0+
- Xcode 9.x (Swift 3.x)

## Installation

### [CocoaPods](http://cocoapods.org/):

In your `Podfile`:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod "GSRefresh"
```

And in your `*.swift`:
```swift
import GSRefresh
```

### [Carthage](https://github.com/Carthage/Carthage):

In your `Cartfile`:

```
github "wxxsw/GSRefresh"
```

And in your `*.swift`:
```swift
import GSRefresh
```

## License

GSRefresh is available under the MIT license. See the LICENSE file for more info.
