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
	- Adding Rows
	- Removing / Replacing Rows
	- Move Rows
	- Hide / Show Rows
	- Reload Rows
	- Sizing Rows

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

The main class of the package is `ScrollStack`, a subclass of `UIScrollView`. It manages the layout of each row, animations and keep a strong reference to your rows.

However usually you don't want to intantiate this control directly but by calling the `ScrollStackController` class.
It's a view controller which allows you to get the child view controller's managment for free, so when you add/remove a row to the stack you will get the standard UIViewController events for free!

This is an example of initialization in a view controller:

```swift
class MyViewController: UIViewController {

    private var stackController = ScrollStackViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(stackController.view)
    }
    
}
```

Now you are ready to use the `ScrollStack` control inside the `stackController` class.
`ScrollStack` have an extensible rich set of APIs to manage your layout: add, remove, move, hide or show your rows, including insets and separator management.

Each row managed by `ScrollStack` is a subclass of `ScrollStackRow`: it strongly reference a parent `UIViewController` class where you content is placed. `UIViewController`'s `view` will be the `contentView` of the row.

You don't need to handle lifecycle of your rows/view controller until they are part of the rows inside the stack.

To get the list of rows of the stack you can use the `rows` property.

```swift
// Standard methods
let allRows = scrollStack.rows
let isEmpty = scrollStack.isEmpty // true if it does not contains row
let notHiddenRows = scrollStack.rows.filter { !$0.isHidden }

// By Vibility
let currentlyVisibleRows = scrollStack.visibleRows // only currently visible rows (partially or enterly)
let enterlyVisibleRows = scrollStack.enterlyVisibleRows // only enterly visible rows into the stack

// Shortcuts
let firstRow = scrollStack.firstRow
let lastRow = scrollStack.lastRow
```

Let's take a look below.

#### Adding Rows

`ScrollStack` provides a comprehensive set of methods for managing rows, including inserting rows at the beginning and end, inserting rows above or below other rows.

To add row you can use one the following methods:

- `addRow(controller:at:animated:) -> ScrollStackRow?`
- `addRows(controllers:at:animated:) -> [ScrollStackRow]?`

Both of these methods takes as arguments:

- `controller/s`: one or more `UIViewController` instances; each view of these controllers will be as a row of the stack inside a `ScrollStackRow` (a sort of cell).
- `at`: specify the insertion point. It's an enum with the following options: `top` (at first index), `bottom` (append at the bottom of the list), `atIndex` (specific index), `after` or `below` (after/below a row which contain a specific `UIViewController`).
- `animated`: if true insertion will be animated
- `completion`: completion callback to call at the end of the operation.

The following code add a rows with the view of each view controller passed:

```swift
   let welcomeVC = WelcomeVC.create()
   let tagsVC = TagsVC.create(delegate: self)
   let galleryVC = GalleryVC.create()
        
   stackView.addRows(controllers: [welcomeVC, notesVC, tagsVC, galleryVC], animated: false)
```

As you noticed there is not need to keep a strong reference to any view controller; they are automatically strong referenced by each row created to add them into the stack.

#### Removing / Replacing Rows

A similar set of APIs are used to remove existing rows from the stack:

- `removeAllRows(animated:)`: to remove all rows of the stack.
- `removeRow(index:animated:) -> UIViewController?`: to remove a specific row at given index. It returns a reference to removed view controller.
- `removeRows(indexes:animated:) -> [UIViewController]?`: to remove rows at specified indexes from the stack. Removed managed `UIViewController` instances are returned.
- `replaceRow(index:withRow:animated:completion:)`: replace an existing row with a new row which manage new passed view controller.

An example:

```swift
let newVC: UIViewController = ...
stackView.replaceRow(index: 1, withRow: galleryVC, animated: true) {
	print("Gallery controller is now in place!!")
}
```

#### Move Rows

If you need to adjust the hierarchy of the stack by moving a row from a position to another you can use:

- `moveRow(index:to:animated:completion:)`: move a row at passed inside to another index (both of indexes must be valid).

The following method move the first row at a random position, by animating the transition:

```swift
let randomDst = Int.random(in: 1..<stackView.rows.count)
stackView.moveRow(index: 0, to: randomDst, animated: true, completion: nil)
```

#### Hide / Show Rows

`ScrollStack` uses the power of `UIStackView`: you can show and hide rows easily with a gorgeous animation by using one of the following methods:

- `setRowHidden(index:isHidden:animated:completion:)`: hide or show a row at index.
- `setRowsHidden(indexes:isHidden:animated:completion:)`: hide or show multiple rows at specified indexes.

Example:

```swift
stackView.setRowsHidden(indexes: [0,1,2], isHidden: true, animated: true)
```

Keep in mind: when you hide a rows the row still part of the stack and it's not removed, just hidden! If you get the list of rows by calling `rows` property of the `ScrollStack` you still see it.

#### Reload Rows

Reload rows method allows you to refresh the layout of the entire stack (using `layoutIfNeeded()`) while you have a chance to update a specific row's `contentView` (aka the view of the managed `UIViewController`).

There are three methods:

- `reloadRow(index:animated:completion:)`: reload a specific row at index.
- `reloadRows(indexes:animated:completion:)`: reload a specific set of rows.
- `reloadAllRows(animated:completion:)`: reload all rows.

If your `UIViewController` implements `ScrollStackContainableController` protocol you will get notified inside the class about this request, so you have the opportunity to refresh your data:

Example:

```swift
class MyViewController: UIViewController {

	private let scrollStackController = ScrollStackController()
	
	@IBAction func someAction() {
		scrollStackController.stackView.reloadRow(0)
	}

}

// Your row 0 manages the GalleryVC, so in your GalleryVC implementation:

class GalleryVC: UIViewController, ScrollStackContainableController {

    public func func reloadContentFromStackView(stackView: ScrollStack, row: ScrollStackRow, animated: Bool) {
		// update your UI
	}
	
}
```

#### Sizing Rows

You can control the size of your `UIViewController` inside a row of a `ScrollStack` in two ways:

- Creating contrains in your `UIViewController`'s view with Autolayout.
- Implementing `ScrollStackContainableController` protocol in your `UIViewController` class and return a non `nil` value in `scrollStackRowSizeForAxis(:row:in:) -> ScrollStack.ControllerSize?` delegate method.

In both case `ScrollStack` class will use only one dimension depending by the active scroll axis to layout the view controller content into the stack (if scroll axis is `horizontal` you can control only the `height` of the row, if it's `vertical` only the `width`. The other dimension will be the same of the scroll stack itself.

