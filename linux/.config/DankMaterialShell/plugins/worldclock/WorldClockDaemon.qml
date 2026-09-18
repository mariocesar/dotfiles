import QtQuick
import Quickshell.Io
import qs.Common

Item {
    id: root

    property var pluginService: null
    property string pluginId: "worldclock"
    readonly property var dialog: dialogLoader.item

    Connections {
        target: root.pluginService
        function onGlobalVarChanged(pluginId, varName) {
            if (pluginId === root.pluginId && varName === "openRequested")
                afterLauncher.restart();
        }
    }

    Timer {
        id: afterLauncher
        interval: Theme.modalAnimationDuration + 50
        onTriggered: dialog.show()
    }

    Loader {
        id: dialogLoader
        // DMS busts the daemon's cache on reload, but not its local QML types.
        source: Qt.resolvedUrl("WorldClockDialog.qml") + "?v=" + Date.now()
    }

    IpcHandler {
        target: "worldclock"
        function open(): string { dialog.show(); return "World Clock opened"; }
        function close(): string { dialog.close(); return "World Clock closed"; }
        function refresh(): string { dialog.fetch(); return "Refresh requested"; }
        function mode(value: string): string {
            if (value !== "today" && value !== "around-now")
                return "Use today or around-now";
            dialog.mode = value;
            return value;
        }
        function status(): string {
            return JSON.stringify({visible: dialog.shouldBeVisible, mode: dialog.mode,
                polling: dialog.polling, fetching: dialog.fetching, error: dialog.error,
                generated_at: dialog.data?.generated_at ?? null});
        }
    }
}
