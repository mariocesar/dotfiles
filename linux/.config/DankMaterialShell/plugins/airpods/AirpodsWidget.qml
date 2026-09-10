import QtQuick
import QtQuick.Layouts
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

    property bool busy: false

    // The script notifies every outcome itself and can take ~30 s; the default 10 s timeout would kill it mid-switch
    function run(action) {
        busy = true
        Proc.runCommand("airpods.action", ["airpods", action], () => {
            busy = false
        }, 0, Proc.noTimeout)
    }

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

    component MenuRow: StyledRect {
        id: row

        property string label
        property string icon
        property string detail: ""
        property bool active: false

        signal clicked

        width: parent.width
        height: 44
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh
        opacity: widget.busy ? 0.5 : 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingM
            spacing: Theme.spacingS

            DankIcon {
                name: row.icon
                color: row.active ? Theme.primary : Theme.surfaceText
                size: Theme.iconSize
            }

            StyledText {
                Layout.fillWidth: true
                text: row.label
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeMedium
            }

            StyledText {
                text: row.detail
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                visible: row.detail !== ""
            }

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: Theme.primary
                visible: row.active
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !widget.busy
            cursorShape: Qt.PointingHandCursor
            onClicked: row.clicked()
        }
    }

    horizontalBarPill: Component {
        Glyph {}
    }

    verticalBarPill: Component {
        Glyph {}
    }

    popoutWidth: 280

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: widget.dev?.name ?? "AirPods"
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingXS

                MenuRow {
                    label: "Music"
                    icon: "earbuds"
                    active: widget.node !== null && !widget.hfp
                    detail: active ? widget.codec.toUpperCase() : "A2DP"
                    onClicked: {
                        widget.run("music")
                        popout.closePopout()
                    }
                }

                MenuRow {
                    label: "Call"
                    icon: "headset_mic"
                    active: widget.hfp
                    detail: active ? widget.codec.toUpperCase() : "HFP"
                    onClicked: {
                        widget.run("call")
                        popout.closePopout()
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.outlineVariant
                }

                MenuRow {
                    label: "Reconnect"
                    icon: "refresh"
                    onClicked: {
                        widget.run("reconnect")
                        popout.closePopout()
                    }
                }
            }
        }
    }
}
