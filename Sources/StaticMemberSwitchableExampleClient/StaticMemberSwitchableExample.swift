import Foundation
import StaticMemberSwitchable

@StaticMemberSwitchable struct Example {
    static let foo: Self = .init(value: "foo")
    static let bar: Self = .init(value: "bar")
    static let baz: Self = .init(value: "baz")

    var value: String
}

func testStaticMemberSwitchable() {
    let values: [Example] = [.foo, .bar, .baz]
    for value in values {
        // Exhaustively switch over static members
        switch value.switchable {
        case .foo:
            print("Value is foo")
        case .bar:
            print("Value is bar")
        case .baz:
            print("Value is baz")
        }
    }
}
