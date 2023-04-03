import XCTest
@testable import AnyAsyncSequence

final class AnyAsyncSequenceTests: XCTestCase {
    func testAnyAsyncSequence() async throws {
        let sequence = TestSequence()
        try await compareSequence(sequence, sequence.eraseToAnyAsyncSequence())
    }
    
    func testAnyAsyncThrowingSequence() async throws {
        let sequence = TestSequence()
        try await compareSequence(sequence, sequence.eraseToAnyAsyncThrowingSequence())
    }
    
    func testError() async throws {
        let sequence = TestSequence(shouldThrow: true)
        let anySequence = sequence.eraseToAnyAsyncThrowingSequence()
        
        var results = [Int]()
        var anyResults = [Int]()
        
        do {
            for try await element in sequence {
                results.append(element)
            }
            
            XCTFail()
        } catch {
            print(error)
        }
        
        do {
            for try await element in anySequence {
                anyResults.append(element)
            }
            
            XCTFail()
        } catch {
            print(error)
        }
        
        XCTAssertEqual(results, anyResults)
    }
    
    func testUrlLines() async throws {
        let lines = URL(string: "https://www.example.com")!.lines
        try await compareSequence(lines, lines.eraseToAnyAsyncThrowingSequence())
    }
    
    private func compareSequence<S1: AsyncSequence, S2: AsyncSequence>(_ sequence1: S1, _ sequence2: S2) async throws where S1.Element: Equatable, S2.Element == S1.Element {
        var sequence1Results = [S1.Element]()
        var sequence2Results = [S2.Element]()
        
        for try await element in sequence1 {
            sequence1Results.append(element)
        }
        
        for try await element in sequence2 {
            sequence2Results.append(element)
        }
        
        XCTAssertEqual(sequence1Results, sequence2Results)
    }
}

struct TestSequence: AsyncSequence {
    typealias Element = Int
    
    var shouldThrow = false
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(shouldThrow: shouldThrow)
    }
    
    struct AsyncIterator: AsyncIteratorProtocol {
        let shouldThrow: Bool
        
        private var current = 1
        
        init(shouldThrow: Bool) {
            self.shouldThrow = shouldThrow
        }
        
        struct TestError: LocalizedError {
            var errorDescription: String? {
                "test error"
            }
        }
        
        mutating func next() async throws -> Element? {
            try Task.checkCancellation()
            
            guard current <= 10 else {
                return nil
            }
            
            if shouldThrow && current == 5 {
                throw TestError()
            }

            let result = current
            current += 1
            return result
        }
    }
}
