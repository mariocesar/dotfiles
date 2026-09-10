import QtQuick
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: widget

    // Presence from Bluetooth, never PipeWire: every profile switch recreates the node
    readonly property var dev: BluetoothService.devices?.values
        ?.find(d => d.connected && (d.icon ?? "").startsWith("audio-")) ?? null
    readonly property bool connected: dev !== null
    readonly property var node: dev ? (Pipewire.nodes.values.find(n =>
        n.isSink && n.properties?.["api.bluez5.address"] === dev.address) ?? null) : null

    readonly property string profile: node?.properties?.["api.bluez5.profile"] ?? ""
    readonly property string codec: node?.properties?.["api.bluez5.codec"] ?? ""
    readonly property bool hfp: profile.startsWith("headset")

    // properties stay empty on a node nothing has bound
    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(n => n.audio && !n.isStream)
    }

    onConnectedChanged: setVisibilityOverride(connected)
    Component.onCompleted: setVisibilityOverride(connected)

    component Glyph: DankIcon {
        name: widget.hfp ? "headset_mic" : "earbuds"
        // no node: card at off, or a switch in progress
        color: widget.node ? Theme.surfaceText : Theme.surfaceVariantText
        size: widget.iconSize
    }

    horizontalBarPill: Component {
        Glyph {}
    }

    verticalBarPill: Component {
        Glyph {}
    }
}
