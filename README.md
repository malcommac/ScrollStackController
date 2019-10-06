# ScrollStackController
Create complex scrollable layout using UIViewController and simplify your code!

## Introduction
ScrollStackController is a class you can use to create complex layouts using scrollable `UIStackView` but where each row is handled by a separate `UIViewController`; this allows you to keep a great separation of concerns.

You can think of it as `UITableView` but with several differences:

- **Each row is a different `UIViewController` you can manage independently**: no more massimove controllers, a much cleaner layout.
- **Powered by AutoLayout since the beginning**; it uses a combination of UIScrollView + UIStackView to offer an animation friendly controller ideal for fixed and dynamic row sizing.
- **You don't need to struggle yourself with view recycling**: suppose you have a layout composed by several different screens. There is no need of view recycling but it cause a more difficult managment of the layout. With a simpler and safer APIs set `ScrollStackView` is the ideal way to implement such layouts.

## Table of Contents

- Main Features
- System Requirements
- How to use it

### Main Features


|  	| Features Highlights 	|
|---	|---------------------------------------------------------------------------------	|
| 🕺 	| Create complex layout without the boilerplate required by view recyling of `UICollectionView` or `UITableView`. 	|
| 🧩 	| Simplify your architecture by thinking each screen as a separate-indipendent `UIVIewController`. 	|
| 🌈 	| Animate show/hide and resize of rows easily! 	|
| ⏱ 	| Compact code base, less than 1k LOC with no external dependencies. 	|
| 🎯 	| Easy to use and extensible APIs set. 	|
| 🧬 	| It uses standard UIKit components at its core. No magic, just a combination of `UIScrollView`+`UIStackView`. 	|
| 🐦 	| Fully made in Swift 5 from Swift ❥ lovers 	|

### System Requirements

- iOS 9+
- Xcode 10+
- Swift 5+

### How to use it
