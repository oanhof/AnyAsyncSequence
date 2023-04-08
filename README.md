# AnyAsyncSequence

Type erased AsyncSequence for Swift.

This package provides two extension functions for `AsyncSequence`:

```swift
extension AsyncSequence {
    public func eraseToAnyAsyncSequence() -> AnyAsyncSequence<Element>
    public func eraseToAnyAsyncThrowingSequence() -> AnyAsyncThrowingSequence<Element>
}
```
