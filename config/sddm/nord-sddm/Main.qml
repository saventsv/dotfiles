import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#2E3440"

    // This handles the login logic
    function doLogin() {
        sddm.login(userBox.currentText, password.text, sessionBox.currentIndex)
    }

    // Background - Using a solid color first to ensure it loads
    Rectangle {
        anchors.fill: parent
        color: "#2E3440"
    }

    Rectangle {
        id: loginBox
        anchors.centerIn: parent
        width: 400
        height: 500
        color: "#3B4252"
        radius: 8
        border.color: "#4C566A"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 15

            Text {
                text: "Welcome"
                color: "#ECEFF4"
                font.pointSize: 22
                Layout.alignment: Qt.AlignHCenter
            }

            // User Selector
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true
                Text { text: "User"; color: "#D8DEE9" }
                ComboBox {
                    id: userBox
                    Layout.fillWidth: true
                    model: userModel
                    textRole: "name"
                    currentIndex: userModel.lastIndex
                }
            }

            // Password Field
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true
                Text { text: "Password"; color: "#D8DEE9" }
                TextField {
                    id: password
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    focus: true
                    color: "#D8DEE9"
                    background: Rectangle {
                        color: "#2E3440"
                        radius: 4
                        border.color: parent.activeFocus ? "#88C0D0" : "#434C5E"
                    }
                    onAccepted: root.doLogin()
                }
            }

            // Session Selector
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true
                Text { text: "Session"; color: "#D8DEE9" }
                ComboBox {
                    id: sessionBox
                    Layout.fillWidth: true
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex
                }
            }

            Button {
                text: "Login"
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                onClicked: root.doLogin()
            }
        }
    }

    // Power Buttons
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30
        spacing: 20
        Button { text: "Reboot"; onClicked: sddm.reboot() }
        Button { text: "Shutdown"; onClicked: sddm.powerOff() }
    }
}