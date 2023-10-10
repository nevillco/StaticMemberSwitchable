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

    // MARK: Success cases

    func testSuccess_Identifiable() {
        assertMacro(record: false) {
            """
            @StaticMemberSwitchable struct Example: Identifiable {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String
            }
            """
        } expansion: {
            """
            struct Example: Identifiable {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String

                enum StaticMemberSwitchable {
                    case foo
                    case bar
                    case baz
                }
                var switchable: StaticMemberSwitchable {
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

    func testSuccess_Equatable() {
        assertMacro(record: false) {
            """
            @StaticMemberSwitchable struct Example: Equatable {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String
            }
            """
        } expansion: {
            """
            struct Example: Equatable {
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String

                enum StaticMemberSwitchable {
                    case foo
                    case bar
                    case baz
                }
                var switchable: StaticMemberSwitchable {
                    switch self {
                        case .foo: return .foo
                        case .bar: return .bar
                        case .baz: return .baz
                        default: fatalError()
                    }
                }
            }
            """
        }
    }

    // MARK: Failure Cases

    func testFailure_NotAStruct() {
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

    func testFailure_MissingRequiredConformance() {
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
            ╰─ 🛑 StaticMemberSwitchable requires types conform to either Identifiable or Equatable.
                static let foo: Self = .init(id: "foo")
                static let bar: Self = .init(id: "bar")
                static let baz: Self = .init(id: "baz")

                let id: String
            }
            """
        }
    }

}
