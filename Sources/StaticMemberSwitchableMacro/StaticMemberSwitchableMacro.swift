public struct StaticMemberSwitchableMacro: MemberMacro {

    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            throw StaticMemberSwitchableError.notAStruct.diagnostic(node: node)
        }
        // Only include static members with the same type as the declaration’s type.
        let validStaticPropertyTypeNames: Set<String> = [
            structDeclaration.name.trimmedDescription,
            "Self"
        ]
        let staticProperties = declaration.properties.filter { property in
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
        let staticPropertyIdentifiers = staticProperties.map(\.identifier.text)

        let inheritance = structDeclaration.inheritanceClause?.inheritedTypes ?? []
        let declarationInheritsProtocol: (String) -> Bool = { protocolName in
            inheritance.contains { $0.trimmed.description == protocolName }
        }

        let switchValue: String
        let switchCaseForStaticProperty: (String) -> String
        if declarationInheritsProtocol("Identifiable") {
            switchValue = "id"
            switchCaseForStaticProperty = { staticProperty in
                "case Self.\(staticProperty).id: return .\(staticProperty)"
            }
        } else if declarationInheritsProtocol("Equatable") {
            switchValue = "self"
            switchCaseForStaticProperty = { staticProperty in
                "case .\(staticProperty): return .\(staticProperty)"
            }
        } else {
            throw StaticMemberSwitchableError.missingRequiredConformance
                .diagnostic(node: node)
        }

        let cases = staticPropertyIdentifiers
            .map { "case \($0)" }
            .joined(separator: "\n")
        return [
            """
            enum StaticMemberSwitchable {
                \(raw: cases)
            }
            var switchable: StaticMemberSwitchable {
                switch \(raw: switchValue) {
                    \(raw: staticPropertyIdentifiers
                    .map(switchCaseForStaticProperty)
                    .joined(separator: "\n        ")
                    )
                    default: fatalError()
                }
            }
            """
        ]
    }

}
