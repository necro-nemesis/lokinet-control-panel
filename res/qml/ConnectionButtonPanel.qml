import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.12

import "."

Container {
    id: connectionButtonPanel
    property var connected: false
    property var running: false

    property color tint: null
    property bool hovering: false

    // bind properties that affect color to updateColor(), which will
    // update our tint property
    onConnectedChanged: updateColor();
    onRunningChanged: updateColor();
    onHoveringChanged: updateColor();

    Layout.preferredHeight: 199
    Layout.preferredWidth: 300

    contentItem: Rectangle {
        id: backgroundRect
        color: Style.panelBackgroundColor
    }

    // static outline
    Image {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/res/images/connection_indicator_outline.png"
    }

    // white connection image; we will colorize with LevelAdjust to indicate
    // status
    Image {
        id: connectionIndicator
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        smooth: true
        source: "qrc:/res/images/connection_indicator.png"
    }

    // colorize connectionIndicator
    LevelAdjust {
        id: level
        anchors.fill: connectionIndicator
        source: connectionIndicator
        maximumOutput: tint
    }

    // handle user interaction
    MouseArea {
        anchors.fill: connectionIndicator
        hoverEnabled: true
        onEntered: {
            hovering = true;
        }
        onExited: {
            hovering = false;
        }
        onPressed: {
            apiClient.llarpAdminWakeup(function(response, err) {
                if (err) {
                    console.log("Received error when trying to wakeup lokinet daemon: ", err);
                }
            });
        }
    }

    function updateColor() {

        // highlight on hover
        const lighter = (hovering ? 1.25 : 1.0);

        let base = "";
        if (connected && running) {
            base = Style.highlightAffirmative
        } else if (connected) {
            // connected, but not running
            base = Style.highlightNeutral
        } else {
            // not connected
            base = Style.highlightNegative
        }
        tint = Qt.lighter(base, lighter);
    }
}

