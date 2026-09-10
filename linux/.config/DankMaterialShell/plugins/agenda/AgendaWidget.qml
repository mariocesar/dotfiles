import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property var agenda: null
    property bool failed: false
    property bool refreshing: false

    readonly property string headline: agenda ? agenda.headline : (failed ? "Agenda unavailable" : "…")
    readonly property bool live: agenda !== null && agenda.current !== null
    readonly property var featured: agenda ? (agenda.current || agenda.next) : null
    readonly property real rowHeight: Theme.fontSizeSmall * 3
    // Proc keys its debouncer by id; a shared one hands every bar's data to the last caller
    readonly property string fetchId: "agenda.fetch." + Math.random().toString(36).slice(2)

    function fetch() {
        Proc.runCommand(fetchId, ["agenda", "--format", "json"], (out, code) => {
            try {
                if (code !== 0)
                    throw new Error("exit " + code);
                agenda = JSON.parse(out);
                failed = false;
            } catch (e) {
                failed = true;
                console.warn("agenda: fetch failed:", e);
            }
            // only the post-sync fetch ends a refresh; the minute poll may land inside the settle window
            if (!syncSettle.running)
                refreshing = false;
        }, 0);
    }

    function refresh() {
        if (refreshing)
            return;
        refreshing = true;
        // "dcal sync" returns before the daemon finishes; give it a moment before re-reading
        Proc.runCommand("agenda.sync", ["dcal", "sync"], () => syncSettle.start(), 0);
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.fetch()
    }

    Timer {
        id: syncSettle
        interval: 3000
        onTriggered: root.fetch()
    }

    component ActionRow: StyledRect {
        id: row

        property alias icon: rowIcon.name
        property alias label: rowText.text
        signal clicked

        width: parent.width
        height: root.rowHeight
        radius: Theme.cornerRadius
        color: rowArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"
        opacity: enabled ? 1 : 0.5

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingM
            spacing: Theme.spacingS

            DankIcon {
                id: rowIcon
                size: Theme.iconSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                id: rowText
                Layout.fillWidth: true
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
            }
        }

        MouseArea {
            id: rowArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.clicked()
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "event"
                size: root.iconSize
                color: root.live ? Theme.primary : Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.headline
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: root.failed && !root.agenda ? Theme.surfaceVariantText : Theme.surfaceText
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                width: Math.min(implicitWidth, Theme.fontSizeSmall * 22)
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        DankIcon {
            name: "event"
            size: root.iconSize
            color: root.live ? Theme.primary : Theme.surfaceText
        }
    }

    popoutWidth: 380

    popoutContent: Component {
        PopoutComponent {
            id: popoutRoot

            headerText: root.agenda ? root.agenda.today_label : "Agenda"
            detailsText: root.headline
            showCloseButton: false

            Connections {
                target: popoutRoot.parentPopout
                function onOpened() {
                    root.fetch();
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingXS

                Repeater {
                    model: root.agenda ? root.agenda.today : []

                    StyledRect {
                        id: eventRow

                        readonly property string link: modelData.meeting_url || modelData.url || ""
                        readonly property bool declined: modelData.rsvp === "declined"
                        readonly property bool ended: !modelData.all_day && root.agenda !== null && new Date(modelData.end) <= new Date(root.agenda.now)
                        readonly property bool featured: root.featured !== null && modelData.uid === root.featured.uid && modelData.start === root.featured.start
                        readonly property color textColor: declined || ended ? Theme.surfaceVariantText : Theme.surfaceText

                        width: parent.width
                        height: root.rowHeight
                        radius: Theme.cornerRadius
                        color: link && eventArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingS

                            StyledText {
                                Layout.preferredWidth: Theme.fontSizeSmall * 5
                                text: modelData.all_day ? "All day" : Qt.formatTime(new Date(modelData.start), "HH:mm")
                                font.pixelSize: Theme.fontSizeSmall
                                font.strikeout: eventRow.declined
                                color: eventRow.featured && !eventRow.declined ? Theme.primary : eventRow.textColor
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.title
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: eventRow.featured ? Font.Bold : Theme.fontWeight
                                font.strikeout: eventRow.declined
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                                color: eventRow.textColor
                            }

                            DankIcon {
                                name: modelData.meeting_url ? "videocam" : "open_in_new"
                                size: Theme.iconSizeSmall
                                color: Theme.surfaceVariantText
                                visible: eventRow.link !== ""
                            }
                        }

                        MouseArea {
                            id: eventArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: eventRow.link !== ""
                            cursorShape: eventRow.link ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                Quickshell.execDetached(["xdg-open", eventRow.link]);
                                popoutRoot.closePopout();
                            }
                        }
                    }
                }

                StyledText {
                    width: parent.width
                    height: root.rowHeight
                    leftPadding: Theme.spacingM
                    text: "No events"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                    visible: root.agenda !== null && root.agenda.today.length === 0
                }

                Item {
                    width: parent.width
                    height: Theme.spacingS * 2 + 1

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: 1
                        color: Theme.outlineMedium
                    }
                }

                ActionRow {
                    icon: "refresh"
                    label: root.refreshing ? "Refreshing…" : "Refresh"
                    enabled: !root.refreshing
                    onClicked: root.refresh()
                }

                ActionRow {
                    icon: "settings"
                    label: "Settings"
                    onClicked: {
                        Quickshell.execDetached(["agenda", "config"]);
                        popoutRoot.closePopout();
                    }
                }
            }
        }
    }
}
