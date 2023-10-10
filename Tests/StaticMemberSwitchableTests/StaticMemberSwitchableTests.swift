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
                static let a: Self = .init(id: "foo")
                static let b = Self.init(id: "bar")
                static let c = Self(id: "baz")
                static let d: Example = .init(id: "qux")
                static let e = Example(id: "qux")
                static let f = Example.init(id: "thud")

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String
            }
            """
        } expansion: {
            """
            struct Example: Identifiable {
                static let a: Self = .init(id: "foo")
                static let b = Self.init(id: "bar")
                static let c = Self(id: "baz")
                static let d: Example = .init(id: "qux")
                static let e = Example(id: "qux")
                static let f = Example.init(id: "thud")

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String

                enum StaticMemberSwitchable {
                    case a
                    case b
                    case c
                    case d
                    case e
                    case f
                }
                var switchable: StaticMemberSwitchable {
                    switch id {
                        case Self.a.id: return .a
                        case Self.b.id: return .b
                        case Self.c.id: return .c
                        case Self.d.id: return .d
                        case Self.e.id: return .e
                        case Self.f.id: return .f
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
                static let a: Self = .init(id: "foo")
                static let b = Self.init(id: "bar")
                static let c = Self(id: "baz")
                static let d: Example = .init(id: "qux")
                static let e = Example(id: "qux")
                static let f = Example.init(id: "thud")

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String
            }
            """
        } expansion: {
            """
            struct Example: Equatable {
                static let a: Self = .init(id: "foo")
                static let b = Self.init(id: "bar")
                static let c = Self(id: "baz")
                static let d: Example = .init(id: "qux")
                static let e = Example(id: "qux")
                static let f = Example.init(id: "thud")

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String

                enum StaticMemberSwitchable {
                    case a
                    case b
                    case c
                    case d
                    case e
                    case f
                }
                var switchable: StaticMemberSwitchable {
                    switch self {
                        case .a: return .a
                        case .b: return .b
                        case .c: return .c
                        case .d: return .d
                        case .e: return .e
                        case .f: return .f
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
