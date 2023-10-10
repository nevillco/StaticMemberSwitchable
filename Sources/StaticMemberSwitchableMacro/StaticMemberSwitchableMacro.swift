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

        let cases = staticPropertyIdentifiers
            .map { "case \($0)" }
            .joined(separator: "\n")

        return [
            """
            enum StaticMemberSwitchable {
                \(raw: cases)
            }
            var switchable: StaticMemberSwitchable {
                switch id {
            \(raw: staticPropertyIdentifiers
            .map { "        case Self.\($0).id: return .\($0)" }
            .joined(separator: "\n")
            )
                    default: fatalError()
                }
            }
            """
        ]
    }

}
