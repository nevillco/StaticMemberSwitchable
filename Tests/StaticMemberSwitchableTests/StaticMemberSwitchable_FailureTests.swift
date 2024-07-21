import MacroTesting
import StaticMemberSwitchableMacro
import XCTest

final class StaticMemberSwitchable_FailureTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(
            record: false,
            macros: ["StaticMemberSwitchable": StaticMemberSwitchableMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testIdentifiable_InternalAccessLevel() {
        assertMacro {
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

                internal enum StaticMemberSwitchable {
                    case a
                    case b
                    case c
                    case d
                    case e
                    case f
                }
                internal var switchable: StaticMemberSwitchable {
                    Self.switchable(id: self.id)
                }
                internal static func switchable(id: ID) -> StaticMemberSwitchable {
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

    func testIdentifiable_PublicAccessLevel() {
        assertMacro {
            """
            @StaticMemberSwitchable public struct Example: Identifiable {
                public static let a: Self = .init(id: "foo")
                public static let b = Self.init(id: "bar")
                public static let c = Self(id: "baz")
                public static let d: Example = .init(id: "qux")
                public static let e = Example(id: "qux")
                public static let f = Example.init(id: "thud")

                public static let notTheRightType1: Int = 6
                public static let notTheRightType2 = "test"

                let id: String
            }
            """
        } expansion: {
            """
            public struct Example: Identifiable {
                public static let a: Self = .init(id: "foo")
                public static let b = Self.init(id: "bar")
                public static let c = Self(id: "baz")
                public static let d: Example = .init(id: "qux")
                public static let e = Example(id: "qux")
                public static let f = Example.init(id: "thud")

                public static let notTheRightType1: Int = 6
                public static let notTheRightType2 = "test"

                let id: String

                public enum StaticMemberSwitchable {
                    case a
                    case b
                    case c
                    case d
                    case e
                    case f
                }
                public var switchable: StaticMemberSwitchable {
                    Self.switchable(id: self.id)
                }
                public static func switchable(id: ID) -> StaticMemberSwitchable {
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

    func testEquatable_InternalAccessLevel() {
        assertMacro {
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

                internal enum StaticMemberSwitchable {
                    case a
                    case b
                    case c
                    case d
                    case e
                    case f
                }
                internal var switchable: StaticMemberSwitchable {
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

    func testEquatable_PublicAccessLevel() {
        assertMacro {
            """
            @StaticMemberSwitchable public struct Example: Equatable {
                public static let a: Self = .init(id: "foo")
                public static let b = Self.init(id: "bar")
                public static let c = Self(id: "baz")
                public static let d: Example = .init(id: "qux")
                public static let e = Example(id: "qux")
                public static let f = Example.init(id: "thud")

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String
            }
            """
        } expansion: {
            """
            public struct Example: Equatable {
                public static let a: Self = .init(id: "foo")
                public static let b = Self.init(id: "bar")
                public static let c = Self(id: "baz")
                public static let d: Example = .init(id: "qux")
                public static let e = Example(id: "qux")
                public static let f = Example.init(id: "thud")

                static let notTheRightType1: Int = 6
                static let notTheRightType2 = "test"

                let id: String

                public enum StaticMemberSwitchable {
                    case a
                    case b
                    case c
                    case d
                    case e
                    case f
                }
                public var switchable: StaticMemberSwitchable {
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

}
