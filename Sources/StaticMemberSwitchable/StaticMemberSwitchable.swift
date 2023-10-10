@attached(member, names: named(switchable), named(StaticMemberSwitchable))
public macro StaticMemberSwitchable() = #externalMacro(
    module: "StaticMemberSwitchableMacro",
    type: "StaticMemberSwitchableMacro"
)
