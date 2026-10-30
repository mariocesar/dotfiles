import QtQuick

Item {
    property var pluginService: null
    property string pluginId: "worldclock"
    property string trigger: ""

    signal itemsChanged

    function getItems(query) {
        return [{
            name: "World Clock",
            icon: "material:public",
            comment: "Compare city times and working hours",
            action: "worldclock:open",
            categories: ["World Clock"]
        }];
    }

    function executeItem(item) {
        pluginService.setGlobalVar(pluginId, "openRequested", Date.now());
    }
}
