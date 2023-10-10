public struct StaticMemberSwitchableMacro: MemberMacro {

    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        let staticProperties = declaration.properties.filter { property in
            property.accessLevel >= declaration.declAccessLevel && property.isStatic
        }
        let staticPropertyIdentifiers = staticProperties.map(\.identifier.text)

        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            throw StaticMemberSwitchableError.notAStruct.diagnostic(node: node)
        }
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
