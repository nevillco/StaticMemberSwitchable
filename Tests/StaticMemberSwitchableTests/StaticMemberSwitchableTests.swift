import MacroTesting
import StaticMemberSwitchableMacro
import XCTest

final class StaticMemberSwitchableTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(
            macros: ["StaticMemberSwitchable": StaticMemberSwitchableMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testSuccess() {
        assertMacro {
            """
            @StaticMemberSwitchable struct Example {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String
            }
            """
        } expansion: {
            """
            struct Example {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String

                enum Switchable {
                    case foo
                    case bar
                    case baz
                }
                var switchable: Switchable {
                    switch id {
                        case Self.foo.id: return .foo
                        case Self.bar.id: return .bar
                        case Self.baz.id: return .baz
                        default: fatalError()
                    }
                }
            }
            """
        }
    }

}