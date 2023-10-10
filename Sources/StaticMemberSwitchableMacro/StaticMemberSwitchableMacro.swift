// MARK: - StaticMemberSwitchableMacro
public struct StaticMemberSwitchableMacro: MemberMacro {

    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
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

        let conformanceSpecificInfo = try conformanceSpecificInfo(
            declaration: structDeclaration,
            node: node
        )

        let cases = staticPropertyIdentifiers
            .map { "case \($0)" }
            .joined(separator: "\n")
        return [
            """
            enum StaticMemberSwitchable {
                \(raw: cases)
            }
            var switchable: StaticMemberSwitchable {
                switch \(raw: conformanceSpecificInfo.switchValue) {
                    \(raw: staticPropertyIdentifiers
                    .map(conformanceSpecificInfo.makeCaseFromPropertyName)
                    .joined(separator: "\n        ")
                    )
                    default: fatalError()
                }
            }
            """
        ]
    }

}

// MARK: - StaticMemberSwitchableMacro - Private
private extension StaticMemberSwitchableMacro {

    static func validStaticProperties(
        declaration: StructDeclSyntax
    ) -> [VariableDeclSyntax] {
        // Only include static members with the same type as the declaration’s type.
        let validStaticPropertyTypeNames: Set<String> = [
            declaration.name.trimmedDescription,
            "Self"
        ]
        return declaration.properties.filter { property in
            let possibleSelfReferencesArray = [
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
            ]
            let possibleSelfReferences = Set(
                possibleSelfReferencesArray.flatMap { $0 }
            )
            let hasSameType = validStaticPropertyTypeNames
                .intersection(possibleSelfReferences)
                .isEmpty == false
            return hasSameType
            && property.accessLevel >= declaration.declAccessLevel
            && property.isStatic
        }
    }

    static func declaration(
        _ declaration: StructDeclSyntax,
        inheritsProtocolNamed protocolName: String
    ) -> Bool {
        let inheritedProtocols = declaration.inheritanceClause?.inheritedTypes
            .map(\.trimmedDescription) ?? []
        return inheritedProtocols.contains(protocolName)
    }

    struct ConformanceSpecificInfo {
        let switchValue: String
        let makeCaseFromPropertyName: (String) -> String
    }
    static func conformanceSpecificInfo(
        declaration: StructDeclSyntax,
        node: AttributeSyntax
    ) throws -> ConformanceSpecificInfo {
        if self.declaration(
            declaration,
            inheritsProtocolNamed: "Identifiable"
        ) {
            return .init(
                switchValue: "id",
                makeCaseFromPropertyName: { propertyName in
                    "case Self.\(propertyName).id: return .\(propertyName)"
                }
            )
        } else if self.declaration(
            declaration,
            inheritsProtocolNamed: "Equatable"
        ) {
            return .init(
                switchValue: "self",
                makeCaseFromPropertyName: { propertyName in
                    "case .\(propertyName): return .\(propertyName)"
                }
            )
        } else {
            throw StaticMemberSwitchableError.missingRequiredConformance
                .diagnostic(node: node)
        }
    }

}
