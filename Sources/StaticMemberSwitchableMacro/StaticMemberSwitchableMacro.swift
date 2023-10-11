// MARK: - StaticMemberSwitchableMacro
public struct StaticMemberSwitchableMacro: MemberMacro {

    public static func expansion<
        Declaration: DeclGroupSyntax,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            throw StaticMemberSwitchableError
                .notAStruct.diagnostic(node: node)
        }

        let staticPropertyIdentifiers = validStaticProperties(
            declaration: structDeclaration
        ).map(\.identifier.text)

        if self.declaration(
            structDeclaration,
            inheritsProtocolNamed: "Identifiable"
        ) {
            return [
                """
                enum StaticMemberSwitchable {
                    \(raw: staticPropertyIdentifiers
                        .map { "case \($0)" }
                        .joined(separator: "\n")
                    )
                }
                var switchable: StaticMemberSwitchable {
                    Self.switchable(id: self.id)
                }
                static func switchable(id: ID) -> StaticMemberSwitchable {
                    switch id {
                        \(raw: staticPropertyIdentifiers
                            .map { propertyName in
                                "case Self.\(propertyName).id: return .\(propertyName)"
                            }
                            // Hack to make indentation correct on all case values
                            .joined(separator: "\n        ")
                        )
                        default: fatalError()
                    }
                }
                """
            ]
        } else if self.declaration(
            structDeclaration,
            inheritsProtocolNamed: "Equatable"
        ) {
            return [
                """
                enum StaticMemberSwitchable {
                    \(raw: staticPropertyIdentifiers
                        .map { "case \($0)" }
                        .joined(separator: "\n")
                    )
                }
                var switchable: StaticMemberSwitchable {
                    switch self {
                        \(raw: staticPropertyIdentifiers
                            .map { propertyName in
                                "case .\(propertyName): return .\(propertyName)"
                            }
                            // Hack to make indentation correct on all case values
                            .joined(separator: "\n        ")
                        )
                        default: fatalError()
                    }
                }
                """
            ]
        } else {
            throw StaticMemberSwitchableError.missingRequiredConformance
                .diagnostic(node: node)
        }
    }

}

// MARK: - StaticMemberSwitchableMacro - Private
private extension StaticMemberSwitchableMacro {

    // MARK: Valid Static Properties

    static func validStaticProperties(
        declaration: StructDeclSyntax
    ) -> [VariableDeclSyntax] {
        // Only include static members with the same type as the declaration.
        let validStaticPropertyTypeNames: Set<String> = [
            // Explicit type of the @StaticMemberSwitchable struct
            declaration.name.trimmedDescription,
            "Self"
        ]
        // There are several different ways to structure a valid static member.
        // Collect all of them and check for set intersection with above values.
        return declaration.properties.filter { property in
            let possibleSelfReferences = Set(
                [
                    // static let ___: Self = ...
                    property.bindings
                        .compactMap(\.typeAnnotation?.type.trimmedDescription),
                    // static let ___ = Self.init(...
                    property.bindings
                        .compactMap(\.initializer?.value)
                        .compactMap { value in
                            value.as(FunctionCallExprSyntax.self)?
                                .calledExpression
                                .as(MemberAccessExprSyntax.self)?
                                .base?.trimmedDescription
                        },
                    // static let ___ = Self(...
                    property.bindings
                        .compactMap(\.initializer?.value)
                        .compactMap { value in
                            value .as(FunctionCallExprSyntax.self)?
                                .calledExpression
                                .as(DeclReferenceExprSyntax.self)?
                                .trimmedDescription
                        }
                ].flatMap { $0 }
            )
            let hasSameTypeAsDeclaration = validStaticPropertyTypeNames
                .intersection(possibleSelfReferences)
                .isEmpty == false
            return hasSameTypeAsDeclaration
            && property.accessLevel >= declaration.declAccessLevel
            && property.isStatic
        }
    }

    // MARK: Protocol Inheritance

    static func declaration(
        _ declaration: StructDeclSyntax,
        inheritsProtocolNamed protocolName: String
    ) -> Bool {
        let inheritedProtocols = declaration
            .inheritanceClause?.inheritedTypes
            .map(\.trimmedDescription) ?? []
        return inheritedProtocols.contains(protocolName)
    }

}
