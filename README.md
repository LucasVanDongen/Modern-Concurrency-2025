# Modern Concurrency - Swift 6.2 Suite of Examples

## Introduction

This is a suite of examples how to apply Swift Concurrency patterns for both Modern (SwiftUI) and Legacy (UIKit) based projects and features.

## Examples
We'll discuss the following reactive programming patterns that are compatible with Modern Concurrency:

* **`@Observable`:**
    * [**Simple SwiftUI Example:**](#simple-swiftui-example-for-observable) Shows the most bare-bones usage of `@Observable`
    * [**Model through ViewModel:**](#model-through-viewmodel-using-observable) Shows how you can chain `@Observable` classes
    * [**Observable to UIKit:**](#new-in-xcode-26---observable-to-uikit) When accessing values from the right UIViewController or UIView functions, tracking and updating of @Observable fields is now automatic for UIKit 
    * [**Observations to UIKit:**](#also-new-observations) A Modern Concurrency-proof alternative for `withObservationTracking`- very useful for legacy code like UIKit, changes the field into an AsyncStream
* **`AsyncChannel``:**
    * [**Single Channel:**](#single-asyncchannel-for-one-consumer) Example how the single `AsyncChannel` consumer works well with one listener
    * [**Single Channel, Multiple Consumers:**](#single-asyncchannel-with-multiple-consumers) Shows us how unexpercted it behaves when you have more than one listener
    * [**Multi Channel:**](#multiasyncchannel-example) If we give an `AsyncChannel` per listener, everything works for multicasts
    * [**Debounce and Throttle:**](#debounce-throttle-and-other-async-algorithms-functions) Example how debounce and throttle work for AsyncChannels


## Prerequisites
* Xcode 26 beta 1
* iOS Simulators installed

## `@Observable`
The [`@Observable` macro](https://developer.apple.com/documentation/observation/observable()) is a way to make all properties in a class reactive, unless you opt out using `@ObservationIgnored`. It's a great way to bind Models or ViewModels to SwiftUI Views. But they were quite limited compared to the Combine-based `@ObservedObject` / `@Published` alternative, until now.

### Simple SwiftUI Example for Observable
A very simple example of how SwiftUI can consume `@Observable` values directly from a Model looks like this:

```swift
struct ObservableView: View {
    @State var model = ObservableModel()

    var body: some View {
        Text(model.currentValue?.rawValue ?? "No Message")
        Button("Next Message") {
            model.sendMessage()
        }
    }
}

@Observable
@MainActor
final class ObservableModel {
    var currentValue: ChannelMessage?
}
```
_See [ModernConcurrency/Observable/ObservableView.swift](ObservableView.swift) and 
[ModernConcurrency/Observable/ObservableModel.swift](ObservableModel.swift)_

It's the way `@Observable` has been working since it's introduction. This works really well for anything you bind directly to a View, but it was pretty limited until the Xcode 26 Beta.

### Model through ViewModel using Observable
One of the more interesting things that was already possible was chaining `@Observable`, for example reflecting values of a Model through a ViewModel:

```swift
@Observable
@MainActor
class ObservableViewModel {
    var text: String {
        // Every change in the Model will update the `text`, and the View that subscribed to it
        model.currentValue?.rawValue ?? "No Value"
    }

    private let model = ObservableModel()

    init() {
        let model = model
    }

    func sendMessage() {
        model.sendMessage()
    }
}
```

_See [ModernConcurrency/Observable/ObservableViewModel.swift](ObservableViewModel.swift) and 
[ModernConcurrency/Observable/ObservableViewModelView.swift](ObservableViewModelView.swift)_

Still it was not possible to do anything else than this. If you wanted to have an `AsyncChannel` so functions like throttling could be applied, you needed to do this manually.

This is an example of a field being mapped to a Channel:

```swift
@Observable
@MainActor
class FunctionsPublisher {
    let channel = AsyncMulticast<String>()
    var currentMessage = "" {
        didSet {
            Task {
                await sendCurrent()
            }
        }
    }

    func sendCurrent() {
        Task { [weak channel] in
            await channel?.send(currentMessage)
        }
    }
}
```
_See [ModernConcurrency/Functions/FunctionsPublisher.swift](FunctionsPublisher.swift)_

While the `@Published`-to-`AnyPublisher` ergonomics of Combine already left something to be desired, this is even more complicated because of Strict Concurrency limitations.

### New in Xcode 26 - Observable to UIKit
Now this one is a fun one to share, because since Xcode 26 (backported to iOS 18) it's now possible to have automatically updated views by accessing `@Observable` properties in certain specific methods on a `UIViewController`:

```swift
override func updateProperties() {
    // Another point to update values, slightly more efficient than `viewWillLayoutSubviews`
    // Trigger it with `setNeedsUpdateProperties()`

    super.updateProperties()
}

override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    // This gets triggered any time the `text` property gets updated on the `model`
    messageLabel.text = model.text
}
```
_See [ModernConcurrency/Observable/ObservableLegacyViewController.swift](ViewController.swift) and 
[ModernConcurrency/Observable/ObservableLegacyViewControllerWrapper.swift](ViewControllerWrapper.swift)_

This, together with other updates on `@Observable` is huge and makes it really interesting to start to move off Combine in earnest starting iOS 18

### Also New: Observations
Another interesting addition, not specifically limited to UIKit, is the `Observations` struct. Strangely, this hadn't been included in the Xcode 26 beta 1 and I had to use a [separate package](https://github.com/phausler/ObservationSequence/) for it to be able to see how it works:

```swift
let names = Observations {
    self.model.text
}
```

In my opinion, this is a game changer. It changes the `@Observable` field into an `AsyncSequence`, which in turns allows you to consume and iterate over it, just like `AsyncChannel`.

```swift
for await name in names {
    self.messageLabel1.text = name
}
```
_See [ModernConcurrency/Observable/ObservationsLegacyViewController.swift](ObservationsLegacyViewController.swift)_

 It also allows you to do everything you could do with a `Sequence`, including throttle and debounce:

```swift
for await name in names._throttle(for: .seconds(0.3)) {
    self.messageLabel2.text = name
}

for await name in names.debounce(for: .seconds(0.3)) {
    self.messageLabel3.text = name
}
```

Before, we had to choose between the ease of use of an `@Observable` field, to be punished with a refactor to `AsyncStream` or `AsyncChannel` if we wanted to do anything more complicated than that.

Another interesting thing is that you can expose them as properties:

```swift
@Observable
@MainActor
class ObservableViewModel {
    var text: String {
        model.currentValue?.rawValue ?? "No Value"
    }

    let observedText: Observations<ChannelMessage?, Never>

    private let model = ObservableModel()

    init() {
        let model = model
        observedText = Observations { model.currentValue }
    }

    func sendMessage() {
        model.sendMessage()
    }
}
```
_See [ModernConcurrency/Observable/ObservableViewModel.swift](ObservableViewModel.swift)_

The great thing about it, is that `observedText` can not be mutated and does not expose a function like `send()`, meaning it's very well encapsulated. In that regard, it's the `@Observable` equivalent of wrapping a `@Published` property in an `AnyPublisher` in Combine.

This as opposed to other options like `CurrentValueSubject` or `AsyncChannel`, that allow the consumer to manipulate it's value or send messages as well. 

## Async Algorithms
[Swift Async Algorithms](https://github.com/apple/swift-async-algorithms) is a great tool for people building more complex Modern Concurrency proof applications. For people working on server-side Swift, where Combine never was available, also the only way to do certain things.

While `AsyncStream` works really well, [`AsyncChannel`](https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Channel.md) also supports back pressure and buffering and can be used across Tasks easily.

### Single AsyncChannel for One Consumer

The principle of an `AsyncChannel` from `AsyncAlgorithms` is simple:
```swift
// First we create a channel we can subscribe to:
class SingleChannelPublisher {
    let channel = AsyncChannel<ChannelMessage>()
}

// Then we consume it through a `.task` on the `View`:
struct SingleChannelConsumerView: View {
    @State private var publisher = SingleChannelPublisher()
    @State private var currentMessage: String?

    var body: some View {
        VStack {
            Text("Current message: \(currentMessage ?? "Waiting for message")")
            Button("Next Message") {
                let publisher = self.publisher
                Task { @MainActor in
                    await publisher.sendMessage()
                }
            }
        }
        .task {
            // This task will be blocked by this `for`-loop
            for await message in publisher.channel {
                currentMessage = message.rawValue
            }
            
            // If you need to subscribe to multiple channels, you need to spawn a task for each

            // Once the Channel reaches the end through `finish()`, it will break out of the `for`-loop
            currentMessage = "Done receiving messages"
        }
    }
}
```
_See 
[ModernConcurrency/Channels/SingleChannelPublisher.swift](SingleChannelPublisher.swift) and 
[ModernConcurrency/Channels/SingleChannelConsumerView.swift](SingleChannelConsumerView.swift)_

This is a nice pattern to use when you want to communicate changes without being bound to the limitations of `@Observable`, or don't want mutable fields on the emitting instance at all.

### Single AsyncChannel with Multiple Consumers
However `AsyncChannel` has a pretty big limitation: it can only support one consumer reliably:

```swift
// ❌ Do not use this code, it's a counter example
struct MultiChannelFailConsumerView: View {
    @State private var publisher = SingleChannelPublisher()
    @State private var currentMessage1: String?
    @State private var currentMessage2: String?

    var body: some View {
        VStack {
            Text("Current message 1: \(currentMessage1 ?? "Waiting for message")")
            Text("Current message 2: \(currentMessage2 ?? "Waiting for message")")
            Button("Next Message") {
                let publisher = self.publisher
                Task { @MainActor in
                    await publisher.sendMessage()
                }
            }
        }
        .task {
            // This task will block the channel until it receives a message
            for await message in publisher.channel {
                currentMessage1 = message.rawValue
            }

            currentMessage1 = "Done receiving messages 1"
        }
        .task {
            // Then it will receive it's next message here, before returning to the first task
            for await message in publisher.channel {
                currentMessage2 = message.rawValue
            }

            currentMessage2 = "Done receiving messages 2"
        }
    }
}
```
_See [ModernConcurrency/Channels/MultiChannelFailConsumerView.swift](MultiChannelFailConsumerView.swift)_

As soon as you start listening from multiple Views, you will notice that it starts behaving in an unexpected way: the received messages will alternate between the tasks, because every `await` on the channel blocks it until it receives a message.

Once the message is received, the next channel gets the opportunity to get it's `await` in, and only that channel gets the next message.

This does not work very well for a lot of applications, where Events and State are emitted to many listeners.

### MultiAsyncChannel Example
The only way I could figure out to make a multicast happen with `AsyncChannel` was by creating an `AsyncMulticast` and `AsyncThrowingMulticast` convenience class that allows you to subscribe many times to a channel:

```swift
class MultiCastPublisher {
    let multicast = AsyncMulticast<ChannelMessage>()
}

// We can `subscribe()` many times to this multicast:
var body: some View {
    VStack {
        MultiCastConsumerView(channel: publisher.multicast.subscribe(), publisher: publisher)
        MultiCastConsumerView(channel: publisher.multicast.subscribe(), publisher: publisher)
    }
}
```
_See 
[ModernConcurrency/Channels/MultiCastPublisher.swift](MultiCastPublisher.swift) and 
[ModernConcurrency/Channels/MultiCastConsumerView.swift](MultiCastConsumerView.swift)_

A strange omission in the otherwise complete Async Algorithms package, I've built this myself, using a `weak`ly retained `Array` of `AsyncChannel`s

```swift
class AsyncMulticast<Element: Sendable>: AsyncMulticasting {
    private var channels = [Weak<AsyncChannel<Element>>]()

    typealias Element = Element

    /// Subscribe to the `AsyncMulticast`, returns your `AsyncChannel`
    func subscribe() -> AsyncChannel<Element> {
        let channel = AsyncChannel<Element>()

        channels = channels.filter { $0.value != nil } + [Weak(value: channel)]

        return channel
    }

    /// Sends an element to an awaiting iteration. This function will resume when the next call to `next()` is made
    /// or when a call to `finish()` is made from another task.
    /// If the channel is already finished then this returns immediately.
    /// If the task is cancelled, this function will resume without sending the element.
    /// Other sending operations from other tasks will remain active.
    func send(_ element: Element) async {
        for channel in channels {
            await channel.value?.send(element)
        }
    }

    /// Immediately resumes all the suspended operations.
    /// All subsequent calls to `next(_:)` will resume immediately.
    func finish() {
        for channel in channels {
            channel.value?.finish()
        }
    }
}
```
_See [ModernConcurrency/Channels/AsyncMulticast.swift](AsyncMulticast.swift)_

### Debounce, Throttle and Other Async Algorithms Functions
`AsyncChannel`s support often-used functions like throtltle and debounce as well:

```swift
struct ThrottleView: View {
    @State var publisher: FunctionsPublisher
    @State var updatesChannel: AsyncChannel<String>
    @State var updatesDebouncedChannel: AsyncChannel<String>
    @State var updatesThrottledChannel: AsyncChannel<String>
    @State var updates = 0
    @State var updatesDebounced = 0
    @State var updatesThrottled = 0

    init(publisher: FunctionsPublisher) {
        self.publisher = publisher
        updatesChannel = publisher.channel.subscribe()
        updatesDebouncedChannel = publisher.channel.subscribe()
        updatesThrottledChannel = publisher.channel.subscribe()
    }

    var body: some View {
        VStack {
            Text("Updates: \(updates)")
            Text("Debounced updates: \(updatesDebounced)")
            Text("Throttled updates: \(updatesThrottled)")
            TextField("Start typing text here", text: $publisher.currentMessage)    
        }
        .task {
            for await _ in updatesChannel {
                updates += 1
            }
        }
        .task {
            for await _ in updatesDebouncedChannel.debounce(for: .seconds(0.5)) {
                updatesDebounced += 1
            }
        }
        .task {
            for await _ in updatesThrottledChannel._throttle(for: .seconds(0.5)) {
                updatesThrottled += 1
            }
        }
    }
}
```
_See [ModernConcurrency/Functions/FunctionsPublisher.swift](FunctionsPublisher.swift) and 
[ModernConcurrency/Functions/ThrottleView.swift](ThrottleView.swift)_

`AsyncChannel` and `AsyncSequence` are more or less equivalent in this regard. When dealing with State on `@MainActor`, `@Observable` and `AsyncSequence` are the best choices in almost any scenario. But when we need to be able to communicate between Actors, need backpressure or buffering `AsyncChannel`s are a great choice.

## Is It Finally Time to Migrate to Swift Concurrency?
Many developers have held off Modern Concurrency and `@Observable` because they have legacy codebases:

* Lots of blocks, that don't work well with safe concurrency
* UIKit based apps, that didn't get any of the SwiftUI `@Observable` goodies so far
* Lack of features and guidelines how to use it

In my opinion, any app that supports iOS 18 as it's minimum version, should abandon Combine (or older patterns) in favor of Modern Concurrency-proof patterns, even when not enabling Swift Concurrency yet. 

Now `@Observable` got UIKit and `AsyncSequence` support, you should start using `@MainActor` and `@Observable` on all of your core app's State, as soon as your minimum OS version allows it.

A lot of mobile applications have a "Current + Previous" OS support strategy, meaning that starting from September the minimum OS version would be sufficient to start migrating over.

While enabling Strict Concurrency in large legacy apps is definitely a bridge too far, teams that were smart to adopt a Modular structure already can migrate per Package.

In my opinion, it's time to start defining the new patterns and practices you're going to work with right now, so you are ready by September

--------

# Old / Not Implemented Yet

* Two Packages: __To be done once I can actually work with 6.2 in Packages__
    * **Default Isolation** by setting it in it's Local Package https://www.massicotte.org/default-isolation-swift-6_2
    * **Standard Isolation** by doing nothing
* They both cover the same subjects _probably I should make a child package_
    * SwiftUI
    * UIKit
    * Observable
    * Observable through multiple layers
    * Channels
    * Multi-Channels
    * Protocol abstractions
    * Debounce

## Prerequisites - old

At the time of writing Swift 6.2 was not part of Xcode yet.

* **Download Swift 6.2:**: If this is not part of your Xcode install, you need to [download it](https://download.swift.org/swift-6.2-branch/xcode/swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-30-a/swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-30-a-osx.pkg) separately 
* **Toolchain:** Follow instructions to select the default Toolchain system-wide:
    1. Set the toolchain in Xcode:
        * Top menu: Xcode -> ToolChains -> Swift 6.2
    2. Find available toolchains:
        * `ls -la /Library/Developer/Toolchains/` 
        * `ls -la ~/Library/Developer/Toolchains/` 
            Note the exact name (e.g., `swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-30-a.xctoolchain`)
    3. Set the appropriate toolchain:
        * For named toolchains: `export TOOLCHAINS=swift` (if there's a symlink)
        * Or with full identifier: `export TOOLCHAINS=swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-30-a`
    4. Verify it's working:
        * `xcrun --find swift` (should point to the new toolchain)
        * `swift --version` (should show Swift 6.2)
    5. Make it permanent:
        * Add `export TOOLCHAINS=swift` to your `~/.zshrc` file by running `echo 'export TOOLCHAINS=swift' >> ~/.zshrc`
        * Apply changes with `source ~/.zshrc`
    6. Test in a new terminal: Run `swift --version` to confirm it's using Swift 6.2

Use with Swift packages: Set the tools version in Package.swift to match your toolchain: // swift-tools-version: 6.2

## Possible Issues
Error:
`'/Library/Developer/Toolchains/swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-30-a.xctoolchain/usr/lib/clang/17/lib/darwin/libclang_rt.profile_iossim.a' not found`

Solve with:
`sudo cp xcode-select -p/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/ /lib/darwin/libclang_rt. .a /Library/Developer/Toolchains/swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-30-a.xctoolchain/usr/lib/clang/7.0.0/lib/darwinc`


Observable Examples
Simple SwiftUI Example:

ModernConcurrency/Observable/ObservableView.swift
ModernConcurrency/Observable/ObservableModel.swift
Model through ViewModel:

ModernConcurrency/Observable/ObservableViewModel.swift
ModernConcurrency/Observable/ObservableViewModelView.swift
Observable to UIKit:

ModernConcurrency/Observable/ObservableLegacyViewController.swift
ModernConcurrency/Observable/ObservableLegacyViewControllerWrapper.swift
Observations:

ModernConcurrency/Observable/ObservationsLegacyViewController.swift
ModernConcurrency/Observable/ObservationsLegacyViewControllerWrapper.swift
AsyncChannel Examples
Single Channel:

ModernConcurrency/Channels/SingleChannelPublisher.swift
ModernConcurrency/Channels/SingleChannelConsumerView.swift
Single Channel, Multiple Consumers:

ModernConcurrency/Channels/MultiChannelFailConsumerView.swift
Multi Channel:

ModernConcurrency/Channels/MultiCastPublisher.swift
ModernConcurrency/Channels/MultiCastConsumerView.swift
ModernConcurrency/Channels/AsyncMulticast.swift
Debounce and Throttle:

ModernConcurrency/Functions/FunctionsPublisher.swift
ModernConcurrency/Functions/ThrottleView.swift
