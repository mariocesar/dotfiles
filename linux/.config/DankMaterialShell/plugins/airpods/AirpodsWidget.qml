import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: widget

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
