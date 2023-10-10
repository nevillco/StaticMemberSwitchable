import Foundation
import StaticMemberSwitchable

@StaticMemberSwitchable struct Example {
    static let foo: Self = .init(value: "foo")
    static let bar: Self = .init(value: "bar")
    static let baz: Self = .init(value: "baz")

    var value: String
}

func testStaticMemberSwitchable() {
    for value in Example.allStaticMembers {
        print(value.value)
    }
}
