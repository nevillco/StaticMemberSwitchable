import MacroTesting
import StaticMemberSwitchableMacro
import XCTest

final class StaticMemberSwitchable_SuccessTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(
            record: false,
            macros: ["StaticMemberSwitchable": StaticMemberSwitchableMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testNotAStruct() {
        assertMacro {
            """
            @StaticMemberSwitchable enum Example {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String
            }
            """
        } diagnostics: {
            """
            @StaticMemberSwitchable enum Example {
            ┬──────────────────────
            ╰─ 🛑 StaticMemberSwitchable only supports struct values.
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String
            }
            """
        }
    }

    func testNoStaticMembers() {
        assertMacro {
            """
            @StaticMemberSwitchable struct Example: Equatable {

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String
            }
            """
        } diagnostics: {
            """
            @StaticMemberSwitchable struct Example: Equatable {
            ┬──────────────────────
            ╰─ 🛑 No static members found in declaration. Make sure the static members are not in a separate extension.

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String
            }
            """
        }
    }

    func testNoStaticMembersWithAccessLevel() {
        assertMacro {
            """
            @StaticMemberSwitchable public struct Example: Equatable {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String
            }
            """
        } diagnostics: {
            """
            @StaticMemberSwitchable public struct Example: Equatable {
            ┬──────────────────────
            ╰─ 🛑 No static members with public access level found. Static members must have at least the same access level as the enclosing type.
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String
            }
            """
        }
    }

    func testMissingRequiredConformance() {
        assertMacro {
            """
            @StaticMemberSwitchable struct Example {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String
            }
            """
        } diagnostics: {
            """
            @StaticMemberSwitchable struct Example {
            ┬──────────────────────
            ╰─ 🛑 Types must conform to either Equatable or Identifiable in the same declaraction that they use @StaticMemberSwitchable.
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String
            }
            """
        }
    }

}
