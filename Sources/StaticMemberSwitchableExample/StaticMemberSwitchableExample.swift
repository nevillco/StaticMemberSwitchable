import Foundation
import StaticMemberSwitchable

@StaticMemberSwitchable struct ExampleIdentifiable: Identifiable {
    static let foo: Self = .init(id: "foo")
    static let bar = Self.init(id: "bar")
    static let baz: Self = .init(id: "baz")

    let id: String
}

func testIdentifiable() {
    switch ExampleIdentifiable.foo.switchable {
    case .foo:
        print("It’s foo")
    case .bar, .baz:
        fatalError("Don’t worry, it’s not one of these")
    }

    switch ExampleIdentifiable.switchable(id: ExampleIdentifiable.foo.id) {
    case .foo:
        print("For identifiable types, you only need an ID to know which case")
    case .bar, .baz:
        fatalError("Don’t worry, it’s not one of these")
    }
}


@StaticMemberSwitchable struct ExampleEquatable: Equatable {
    static let foo: Self = .init(value: 0)
    static let bar = Self.init(value: 50)
    static let baz: Self = .init(value: 100)

    let value: Int
}

func testEquatable() {
    switch ExampleEquatable.foo.switchable {
    case .foo:
        print("It’s foo")
    case .bar, .baz:
        fatalError("Don’t worry, it’s not one of these")
    }
}
