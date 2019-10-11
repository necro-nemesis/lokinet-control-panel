import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.5

ColumnLayout {
    anchors.fill: parent
    spacing: 1

    property var isConnected: false
    property var isRunning: false
    property var lokiAddress: ""
    property var numPathsBuilt: 0
    property var numRoutersKnown: 0
    property var downloadUsage: 0
    property var uploadUsage: 0

    // other colors
    // strong text: #FAF9FA
    // weak text: #7D8585

    ConnectionHeaderPanel {
        connected: isConnected
        running: isRunning
    }

    // placeholder for main on/off button
    ConnectionButtonPanel {
        connected: isConnected
        running: isRunning
    }

    // address panel
    AddressPanel {
        address: lokiAddress
    }

    // router stats
    RouteStatsPanel {
        paths: numPathsBuilt
        routers: numRoutersKnown
    }

    // placeholder for performance graph panel
    Rectangle {
        color: "#323642"
        Layout.preferredHeight: 159
        Layout.preferredWidth: 300
    }

    // usage
    UsagePanel {
        down: downloadUsage
        up: uploadUsage
    }

    // placeholder / empty space
    Rectangle {
        color: "#323642"
        Layout.preferredHeight: 79
        Layout.preferredWidth: 300
    }

    // dismiss panel
    DismissPanel { }


    Component.onCompleted: {
        statFetcher.statusAvailable.connect(handleStats);
        statFetcher.pollImmediately();
        statFetcher.setIntervalMs(3000);
        statFetcher.startPolling();
    }

    function handleStats(payload) {
        const stats = JSON.parse(payload);

        // calculate our new state in local scope before updating global scope
        let newConnected = true;
        let newRunning = false;
        let newLokiAddress = "";
        let newNumRouters = 0;

        try {
            newRunning = stats.result.running;
        } catch (err) {
            console.log("Couldn't pull running status of payload", err);
        }

        try {
            newLokiAddress = stats.result.services.default.identity;
        } catch (err) {
            console.log("Couldn't pull loki address out of payload", err);
        }

        try {
            newNumRouters = stats.result.numNodesKnown;
        } catch (err) {
            console.log("Couldn't pull numNodesKnown out of payload", err);
        }

        // only update global state if there is actually a change.
        // this prevents propagating state change events when there aren't
        // really changes in the first place
        if (newConnected !== isConnected) isConnected = newConnected;
        if (newRunning !== isRunning) isRunning = newRunning;
        if (newLokiAddress !== lokiAddress) lokiAddress = newLokiAddress;
        if (newNumRouters !== numRoutersKnown) numRoutersKnown = newNumRouters;

    }
}

