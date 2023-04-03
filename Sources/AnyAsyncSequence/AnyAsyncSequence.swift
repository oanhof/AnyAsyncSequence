//
//  AnyAsyncSequence.swift
//
//
//  Created by Dominik Arnhof on 03.04.23.
//

import Foundation

public struct AnyAsyncSequence<Element>: AsyncSequence {
    private let makeIterator: () -> any AsyncIteratorProtocol
    
    init<S: AsyncSequence>(sequence: S) where S.Element == Element {
        makeIterator = { sequence.makeAsyncIterator() }
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(iterator: makeIterator())
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        var iterator: any AsyncIteratorProtocol

        public mutating func next() async -> Element? {
            try? await iterator.next() as? Element
        }
    }
}

public struct AnyAsyncThrowingSequence<Element>: AsyncSequence {
    private let makeIterator: () -> any AsyncIteratorProtocol
    
    init<S: AsyncSequence>(sequence: S) where S.Element == Element {
        makeIterator = { sequence.makeAsyncIterator() }
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(iterator: makeIterator())
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        var iterator: any AsyncIteratorProtocol
        
        public mutating func next() async throws -> Element? {
            try await iterator.next() as? Element
        }
    }
}

extension AsyncSequence {
    func eraseToAnyAsyncSequence() -> AnyAsyncSequence<Element> {
        AnyAsyncSequence(sequence: self)
    }
    
    func eraseToAnyAsyncThrowingSequence() -> AnyAsyncThrowingSequence<Element> {
        AnyAsyncThrowingSequence(sequence: self)
    }
}
