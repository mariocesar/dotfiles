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

    // properties stay empty on a node nothing has bound
    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(n => n.audio && !n.isStream)
    }

    onConnectedChanged: setVisibilityOverride(connected)
    Component.onCompleted: setVisibilityOverride(connected)

    horizontalBarPill: Component {
        DankIcon {
            name: "earbuds"
            color: Theme.surfaceText
            size: widget.iconSize
        }
    }

    verticalBarPill: Component {
        DankIcon {
            name: "earbuds"
            color: Theme.surfaceText
            size: widget.iconSize
        }
    }
}
