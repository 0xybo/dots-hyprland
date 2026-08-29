import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property int totalSeconds: 0
    property int secondsLeft: 0
    property bool running: false
    property int inputHours: 0
    property int inputMinutes: 0
    property int inputSeconds: 0

    function startTimer() {
        if (secondsLeft <= 0) {
            secondsLeft = inputHours * 3600 + inputMinutes * 60 + inputSeconds;
            if (secondsLeft <= 0) return;
        }
        running = true;
    }

    function pauseTimer() {
        running = false;
    }

    function resetTimer() {
        running = false;
        secondsLeft = 0;
    }

    Timer {
        id: countdownTimer
        interval: 1000
        running: root.running
        repeat: true
        onTriggered: {
            if (root.secondsLeft > 0) {
                root.secondsLeft--;
            }
            if (root.secondsLeft <= 0) {
                root.running = false;
                if (root.totalSeconds > 0) {
                    Quickshell.execDetached(["notify-send", "Timer", Translation.tr("Time's up!"), "-a", "Shell"]);
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Timer circle
        CircularProgress {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            lineWidth: 8
            value: root.totalSeconds > 0 ? root.secondsLeft / root.totalSeconds : 1
            implicitSize: 200
            enableAnimation: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        if (!root.running && root.secondsLeft <= 0 && root.totalSeconds > 0) {
                            let m = Math.floor(root.totalSeconds / 60).toString().padStart(2, '0');
                            let s = Math.floor(root.totalSeconds % 60).toString().padStart(2, '0');
                            return `${m}:${s}`;
                        }
                        let hours = Math.floor(root.secondsLeft / 3600);
                        let mins = Math.floor((root.secondsLeft % 3600) / 60).toString().padStart(2, '0');
                        let secs = Math.floor(root.secondsLeft % 60).toString().padStart(2, '0');
                        return hours > 0 ? `${hours}:${mins}:${secs}` : `${mins}:${secs}`;
                    }
                    font.pixelSize: 40
                    color: Appearance.m3colors.m3onSurface
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.running ? Translation.tr("Running") : (root.secondsLeft > 0 ? Translation.tr("Paused") : Translation.tr("Set time"))
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }

            Rectangle {
                radius: Appearance.rounding.full
                color: Appearance.colors.colLayer2
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                implicitWidth: 36
                implicitHeight: implicitWidth
                visible: root.totalSeconds > 0

                StyledText {
                    anchors.centerIn: parent
                    color: Appearance.colors.colOnLayer2
                    text: {
                        let h = Math.floor(root.totalSeconds / 3600);
                        let m = Math.floor((root.totalSeconds % 3600) / 60);
                        let s = Math.floor(root.totalSeconds % 60);
                        return h > 0 ? `${h}h` : (m > 0 ? `${m}m` : `${s}s`);
                    }
                }
            }
        }

        // Time input spinners (only when not running and no time set)
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            spacing: 8
            visible: !root.running && root.secondsLeft <= 0

            TimeSpinner {
                label: Translation.tr("H")
                value: root.inputHours
                max: 99
                onValueChanged: root.inputHours = value
            }
            TimeSpinner {
                label: Translation.tr("M")
                value: root.inputMinutes
                max: 59
                onValueChanged: root.inputMinutes = value
            }
            TimeSpinner {
                label: Translation.tr("S")
                value: root.inputSeconds
                max: 59
                onValueChanged: root.inputSeconds = value
            }
        }

        // Control buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            spacing: 10

            RippleButton {
                implicitHeight: 35
                implicitWidth: 90
                font.pixelSize: Appearance.font.pixelSize.larger
                onClicked: {
                    if (root.running) root.pauseTimer();
                    else root.startTimer();
                }
                enabled: root.secondsLeft > 0 || (root.inputHours + root.inputMinutes + root.inputSeconds > 0)
                colBackground: root.running ? Appearance.colors.colSecondaryContainer : Appearance.colors.colPrimary
                colBackgroundHover: root.running ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colPrimaryHover
                colRipple: root.running ? Appearance.colors.colSecondaryContainerActive : Appearance.colors.colPrimaryActive
                contentItem: StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    color: root.running ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnPrimary
                    text: root.running ? Translation.tr("Pause") : (root.secondsLeft > 0 ? Translation.tr("Resume") : Translation.tr("Start"))
                }
            }

            RippleButton {
                implicitHeight: 35
                implicitWidth: 90
                font.pixelSize: Appearance.font.pixelSize.larger
                onClicked: root.resetTimer()
                enabled: root.secondsLeft > 0 || root.totalSeconds > 0
                colBackground: Appearance.colors.colErrorContainer
                colBackgroundHover: Appearance.colors.colErrorContainerHover
                colRipple: Appearance.colors.colErrorContainerActive
                contentItem: StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: Translation.tr("Reset")
                    color: Appearance.colors.colOnErrorContainer
                }
            }
        }
    }

    component TimeSpinner: ColumnLayout {
        property string label: ""
        property int value: 0
        property int max: 59
        spacing: 2

        Layout.alignment: Qt.AlignHCenter

        RippleButton {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 56
            implicitHeight: 28
            buttonRadius: Appearance.rounding.small
            colBackground: Appearance.colors.colLayer2
            colBackgroundHover: Appearance.colors.colLayer2Hover
            colRipple: Appearance.colors.colLayer2Active
            onClicked: {
                if (value < max) value++;
                else value = 0;
            }
            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                text: "expand_less"
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnLayer2
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 56
            implicitHeight: 36
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colLayer0Border

            StyledText {
                anchors.centerIn: parent
                text: value.toString().padStart(2, '0')
                font.pixelSize: Appearance.font.pixelSize.large
                color: Appearance.m3colors.m3onSurface
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: label
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
        }

        RippleButton {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 56
            implicitHeight: 28
            buttonRadius: Appearance.rounding.small
            colBackground: Appearance.colors.colLayer2
            colBackgroundHover: Appearance.colors.colLayer2Hover
            colRipple: Appearance.colors.colLayer2Active
            onClicked: {
                if (value > 0) value--;
                else value = max;
            }
            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                text: "expand_more"
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnLayer2
            }
        }
    }
}
