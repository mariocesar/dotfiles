import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Modals.Common
import qs.Widgets

DankModal {
    id: root

    property string mode: "today"
    property var data: null
    property string error: ""
    property bool pendingFetch: false
    property bool resetScroll: true
    property string requestedMode: ""
    property bool fetchTimedOut: false
    readonly property bool fetching: fetchDeadline.running
    readonly property bool polling: minuteTimer.running
    readonly property bool stale: data !== null && (error !== "" || data.mode !== mode)
    readonly property real rowHeight: Theme.fontSizeMedium * 6
    readonly property bool hasDefaultShading: data?.cities.some(city => !city.working_hours) ?? true
    readonly property bool hasWorkingHours: data?.cities.some(city => city.working_hours) ?? false

    layerNamespace: "dms:worldclock"
    modalWidth: Math.min(1280, screenWidth - Theme.spacingL * 2)
    modalHeight: Math.min(650, screenHeight - Theme.spacingL * 2,
        contentLoader?.item ? contentLoader.item.implicitHeight + Theme.spacingL * 2 : 440)
    borderWidth: 1
    keepContentLoaded: true
    onBackgroundClicked: close()
    onModeChanged: {
        resetScroll = true;
        if (shouldBeVisible)
            fetch();
    }
    onShouldBeVisibleChanged: {
        if (!shouldBeVisible)
            pendingFetch = false;
    }

    function show() {
        resetScroll = true;
        mode = "today";
        open();
    }

    onOpened: fetch()

    function fetch() {
        if (!shouldBeVisible)
            return;
        if (fetching) {
            pendingFetch = true;
            return;
        }
        pendingFetch = false;
        requestedMode = mode;
        fetchTimedOut = false;
        fetchProcess.command = ["worldclock", "--format", "json", "--mode", mode];
        fetchDeadline.restart();
        fetchProcess.running = true;
    }

    function shade(kind) {
        switch (kind) {
        case "day": return Theme.withAlpha(Theme.primary, 0.32);
        case "twilight": return Theme.withAlpha(Theme.secondary, 0.20);
        case "working": return Theme.withAlpha(Theme.primary, 0.40);
        default: return Theme.surfaceContainerHighest;
        }
    }

    Process {
        id: fetchProcess
        stdout: StdioCollector { id: output }
        stderr: StdioCollector { id: errors }
        onExited: (code, status) => {
            fetchDeadline.stop();
            if (root.shouldBeVisible && root.requestedMode === root.mode) {
                try {
                    if (root.fetchTimedOut)
                        throw new Error("worldclock timed out. Check the command in a terminal, then Refresh.");
                    if (code !== 0)
                        throw new Error(errors.text.trim() || "worldclock failed (exit " + code + "). Check that worldclock is installed in PATH.");
                    const result = JSON.parse(output.text);
                    if (!Array.isArray(result.cities) || result.mode !== root.mode)
                        throw new Error("Unexpected worldclock response. Reload the plugin and CLI together.");
                    root.data = result;
                    root.error = "";
                } catch (e) {
                    root.error = e.message;
                }
            }
            if (root.pendingFetch)
                Qt.callLater(root.fetch);
        }
    }

    Timer {
        id: fetchDeadline
        interval: 10000
        onTriggered: {
            root.fetchTimedOut = true;
            root.error = "worldclock did not complete. Check that it is installed in DMS's PATH, then Refresh.";
            fetchProcess.running = false;
        }
    }

    Timer {
        id: minuteTimer
        interval: 60000
        repeat: true
        running: root.shouldBeVisible
        onTriggered: root.fetch()
    }

    Process {
        id: settingsProcess
        command: ["worldclock", "config"]
        stderr: StdioCollector { id: settingsErrors }
        onExited: (code, status) => {
            if (code !== 0)
                root.error = settingsErrors.text.trim() || "Could not open Settings. Run worldclock config in a terminal.";
        }
    }

    content: Component {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS

                DankIcon {
                    name: "public"
                    size: Theme.iconSizeSmall
                    color: Theme.primary
                }
                StyledText {
                    text: "World Clock"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Medium
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: modes.implicitWidth + 4
                    implicitHeight: modes.implicitHeight + 4
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHighest
                    Row {
                        id: modes
                        anchors.centerIn: parent
                        spacing: 2
                        Repeater {
                            model: [{value: "today", label: "Today"}, {value: "around-now", label: "Around now"}]
                            DankButton {
                                required property var modelData
                                text: modelData.label
                                buttonHeight: 28
                                horizontalPadding: Theme.spacingS
                                backgroundColor: root.mode === modelData.value ? Theme.surfaceContainer : "transparent"
                                textColor: root.mode === modelData.value ? Theme.primary : Theme.surfaceVariantText
                                onClicked: root.mode = modelData.value
                            }
                        }
                    }
                }

                Item { implicitWidth: Theme.spacingXS }
                DankActionButton {
                    iconName: "refresh"
                    Accessible.name: "Refresh"
                    iconSize: Theme.iconSizeSmall
                    buttonSize: 28
                    tooltipText: root.fetching ? "Refreshing…" : "Refresh"
                    opacity: root.fetching ? 0.4 : 1
                    enabled: !root.fetching
                    onClicked: root.fetch()
                }
                DankActionButton {
                    iconName: "settings"
                    Accessible.name: "Settings"
                    iconSize: Theme.iconSizeSmall
                    buttonSize: 28
                    tooltipText: "Edit cities and working hours"
                    enabled: !settingsProcess.running
                    onClicked: settingsProcess.running = true
                }
                Rectangle {
                    implicitWidth: 1
                    implicitHeight: Theme.iconSizeSmall
                    color: Theme.outlineMedium
                }
                DankActionButton {
                    iconName: "close"
                    Accessible.name: "Close"
                    iconSize: Theme.iconSizeSmall
                    buttonSize: 28
                    tooltipText: "Close · Esc"
                    onClicked: root.close()
                }
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.error !== "" || root.stale
                text: (root.stale ? "Stale — showing the previous result. " : "") + root.error
                    + (root.error ? " Use Settings to fix the configuration, then Refresh." : "Updating…")
                color: Theme.error
                wrapMode: Text.Wrap
            }

            StyledText {
                Layout.fillWidth: true
                visible: !root.data || root.data.cities.length === 0
                text: root.data?.message || (root.error ? "World Clock unavailable" : "Loading city times…")
                wrapMode: Text.Wrap
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.data?.timeline !== null && root.data !== null
                text: root.data?.timeline ? (root.data.mode === "today" ? "Home day" : "12h before / after now")
                    + " · " + (root.data.timeline.duration_seconds / 3600) + "h · local time · offsets from home" : ""
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }

            Item {
                id: chart
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: (root.data?.cities.length ?? 2) * root.rowHeight + Theme.spacingL + Theme.spacingM
                clip: true
                readonly property real labelWidth: Math.min(230, width * 0.35)
                readonly property real timelineWidth: Math.max(timelineViewport.width,
                    (root.data?.timeline?.duration_seconds ?? 86400) / 3600 * Theme.fontSizeSmall * 2.8)

                Connections {
                    target: root
                    function onDataChanged() {
                        if (!root.resetScroll)
                            return;
                        Qt.callLater(() => {
                            timelineViewport.contentX = Math.max(0, Math.min(
                                chart.timelineWidth - timelineViewport.width,
                                (root.data?.timeline?.now_position ?? 0) * chart.timelineWidth - timelineViewport.width / 2));
                            verticalViewport.contentY = 0;
                        });
                        root.resetScroll = false;
                    }
                }

                Flickable {
                    id: verticalViewport
                    anchors.fill: parent
                    anchors.bottomMargin: Theme.spacingM
                    contentWidth: width
                    contentHeight: cityLabels.height
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.VerticalFlick
                    clip: true
                    ScrollBar.vertical: ScrollBar {}

                    Column {
                        id: cityLabels
                        width: chart.labelWidth
                        topPadding: Theme.spacingL
                        Repeater {
                            model: root.data?.cities ?? []
                            Item {
                                required property var modelData
                                width: cityLabels.width
                                height: root.rowHeight
                                Column {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacingM
                                    spacing: Theme.spacingXS
                                    StyledText {
                                        width: parent.width
                                        text: (modelData.home ? "⌂ " : "") + modelData.label
                                        font.bold: true
                                        font.pixelSize: Theme.fontSizeMedium
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                    StyledText {
                                        text: modelData.time + "  " + modelData.abbreviation
                                        color: Theme.primary
                                        font.pixelSize: Theme.fontSizeLarge
                                    }
                                    StyledText {
                                        width: parent.width
                                        text: modelData.date + " · " + (modelData.home ? "Home" : modelData.offset_from_home)
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        wrapMode: Text.Wrap
                                    }
                                }
                            }
                        }
                    }
                }

                Flickable {
                    id: timelineViewport
                    anchors.left: parent.left
                    anchors.leftMargin: chart.labelWidth
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingM
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    contentWidth: chart.timelineWidth
                    contentHeight: height
                    flickableDirection: Flickable.HorizontalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

                    WheelHandler {
                        acceptedModifiers: Qt.NoModifier
                        onWheel: event => {
                            if (Math.abs(event.angleDelta.y) > Math.abs(event.angleDelta.x)) {
                                verticalViewport.contentY = Math.max(0, Math.min(
                                    Math.max(0, verticalViewport.contentHeight - verticalViewport.height),
                                    verticalViewport.contentY - event.angleDelta.y));
                                event.accepted = true;
                            } else {
                                event.accepted = false;
                            }
                        }
                    }

                    Column {
                        y: Theme.spacingL - verticalViewport.contentY
                        Repeater {
                            model: root.data?.cities ?? []
                            Item {
                                id: barRow
                                required property var modelData
                                width: chart.timelineWidth
                                height: root.rowHeight
                                Repeater {
                                    model: barRow.modelData.segments
                                    Rectangle {
                                        required property var modelData
                                        x: modelData.start * barRow.width
                                        y: Theme.spacingL
                                        width: (modelData.end - modelData.start) * barRow.width
                                        height: Theme.fontSizeMedium * 3
                                        color: root.shade(modelData.kind)
                                    }
                                }
                                Repeater {
                                    model: barRow.modelData.ticks
                                    Item {
                                        required property var modelData
                                        x: modelData.position * barRow.width
                                        y: Theme.spacingL
                                        Rectangle {
                                            width: 1
                                            height: Theme.fontSizeMedium * 3
                                            color: Theme.withAlpha(Theme.surfaceText, 0.07)
                                        }
                                        StyledText {
                                            visible: modelData.position < 1
                                            x: 4
                                            y: Theme.spacingS
                                            text: modelData.label.replace(":00", "").replace(" (", "\n").replace(")", "")
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
                                        }
                                    }
                                }
                                Repeater {
                                    model: barRow.modelData.date_boundaries
                                    Item {
                                        required property var modelData
                                        x: modelData.position * barRow.width
                                        Rectangle {
                                            width: 2
                                            height: Theme.spacingL + Theme.fontSizeMedium * 3
                                            color: Theme.secondary
                                        }
                                        StyledText {
                                            x: Math.min(4, barRow.width - parent.x - implicitWidth)
                                            text: modelData.date
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.secondary
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        visible: root.data?.timeline !== null && root.data !== null
                        x: Math.min(chart.timelineWidth - width,
                            (root.data?.timeline?.now_position ?? 0) * chart.timelineWidth)
                        width: 2
                        height: Math.min(timelineViewport.height - Theme.spacingM, cityLabels.height)
                        color: Theme.primary
                        StyledText {
                            text: "Now"
                            x: Math.min(4, chart.timelineWidth - parent.x - implicitWidth)
                            color: Theme.primary
                            font.bold: true
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                spacing: Theme.spacingM
                Repeater {
                    model: (root.hasDefaultShading ? [{kind: "day", label: "Day 08–18"},
                        {kind: "twilight", label: "Morning / evening 06–08 · 18–22"},
                        {kind: "night", label: "Night 22–06"}] : []).concat(root.hasWorkingHours ? [
                        {kind: "working", label: "Working hours"},
                        {kind: "outside", label: "Outside work"}] : [])
                    Row {
                        required property var modelData
                        spacing: Theme.spacingXS
                        Rectangle {
                            width: Theme.fontSizeSmall
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.shade(modelData.kind)
                        }
                        StyledText {
                            text: modelData.label
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                    }
                }
            }
        }
    }
}
