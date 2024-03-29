import Foundation

@propertyWrapper
package struct Atomic<Value> {

    private let lock = NSLock()
    private var value: Value

    package init(wrappedValue: Value) {
        value = wrappedValue
    }

    package var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            value = newValue
            lock.unlock()
        }
    }
}
