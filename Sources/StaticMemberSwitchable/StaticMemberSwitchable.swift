@attached(member, names: named(allStaticMembers))
public macro StaticMemberSwitchable() = #externalMacro(
    module: "StaticMemberSwitchableMacro",
    type: "StaticMemberSwitchableMacro"
)
