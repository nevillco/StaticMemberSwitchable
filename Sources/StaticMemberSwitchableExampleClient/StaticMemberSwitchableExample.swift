import Foundation
import StaticMemberSwitchable

@StaticMemberSwitchable struct Example: Identifiable {
    static let foo: Self = .init(id: "foo")
    static let bar: Self = .init(id: "bar")
    static let baz: Self = .init(id: "baz")

    let id: String
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
