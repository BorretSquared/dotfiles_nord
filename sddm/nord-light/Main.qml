/***************************************************************************
* Nord Light SDDM Theme
* Copyright (c) 2025
*
* A clean and modern SDDM theme inspired by the Nord Light color palette,
* perfect for Hyprland setups and minimalist desktop environments.
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    // Nord Light color palette - optimized for light themes
    property color nord0:  "#2e3440"  // polar night darkest (text on light bg)
    property color nord1:  "#3b4252"  // polar night dark
    property color nord2:  "#434c5e"  // polar night medium
    property color nord3:  "#4c566a"  // polar night light (subtle text)
    property color nord4:  "#d8dee9"  // snow storm dark (bg elements)
    property color nord5:  "#e5e9f0"  // snow storm medium (main bg)
    property color nord6:  "#eceff4"  // snow storm light (cards/containers)
    property color nord7:  "#8fbcbb"  // frost teal
    property color nord8:  "#88c0d0"  // frost light blue
    property color nord9:  "#81a1c1"  // frost blue
    property color nord10: "#5e81ac"  // frost dark blue (primary accent)
    property color nord11: "#bf616a"  // aurora red (error/shutdown)
    property color nord12: "#d08770"  // aurora orange (warning/restart)
    property color nord13: "#ebcb8b"  // aurora yellow
    property color nord14: "#a3be8c"  // aurora green (success)
    property color nord15: "#b48ead"  // aurora purple

    // Animated gradient background
    gradient: Gradient {
        GradientStop { position: 0.0; color: nord6 }
        GradientStop { position: 0.6; color: nord5 }
        GradientStop { position: 1.0; color: nord4 }
    }

    // Subtle animated background pattern
    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = nord14
            errorMessage.text = textConstants.loginSucceeded
        }

        onLoginFailed: {
            password.text = ""
            errorMessage.color = nord11
            errorMessage.text = textConstants.loginFailed
        }

        onInformationMessage: {
            errorMessage.color = nord11
            errorMessage.text = message
        }
    }



    // Main login container with glassmorphism effect
    Rectangle {
        id: mainContainer
        anchors.centerIn: parent
        width: 420
        height: 320
        color: Qt.rgba(1, 1, 1, 0.7)
        radius: 24
        border.color: Qt.rgba(1, 1, 1, 0.3)
        border.width: 1

        // Backdrop blur effect simulation with multiple layers
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            color: Qt.rgba(1, 1, 1, 0.1)
            radius: 25
            z: -1
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            color: Qt.rgba(236/255, 239/255, 244/255, 0.1)
            radius: 27
            z: -2
        }

        Column {
            id: mainColumn
            anchors.centerIn: parent
            spacing: 20

            // Username field
            Column {
                spacing: 8
                width: 320
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: textConstants.userName
                    color: nord1
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    font.family: "JetBrains Mono, monospace"
                }

                Rectangle {
                    width: 320
                    height: 48
                    color: Qt.rgba(1, 1, 1, 0.8)
                    border.color: name.activeFocus ? nord10 : Qt.rgba(76/255, 86/255, 106/255, 0.3)
                    border.width: 2
                    radius: 12

                    TextInput {
                        id: name
                        anchors.fill: parent
                        anchors.margins: 16
                        font.pixelSize: 15
                        font.family: "JetBrains Mono, monospace"
                        color: nord0
                        selectByMouse: true
                        selectionColor: nord8
                        selectedTextColor: nord0
                        text: userModel.lastUser
                        KeyNavigation.backtab: rebootButton
                        KeyNavigation.tab: password

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            // Password field
            Column {
                spacing: 8
                width: 320
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: textConstants.password
                    color: nord1
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    font.family: "JetBrains Mono, monospace"
                }

                Rectangle {
                    width: 320
                    height: 48
                    color: Qt.rgba(1, 1, 1, 0.8)
                    border.color: password.activeFocus ? nord10 : Qt.rgba(76/255, 86/255, 106/255, 0.3)
                    border.width: 2
                    radius: 12

                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.margins: 16
                        font.pixelSize: 15
                        font.family: "JetBrains Mono, monospace"
                        color: nord0
                        echoMode: TextInput.Password
                        selectByMouse: true
                        selectionColor: nord8
                        selectedTextColor: nord0
                        KeyNavigation.backtab: name
                        KeyNavigation.tab: session

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            // Login button
            Rectangle {
                width: 320
                height: 48
                color: loginButton.pressed ? nord9 : (loginButton.containsMouse ? nord8 : nord10)
                radius: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: textConstants.login
                    color: nord6
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    font.family: "JetBrains Mono, monospace"
                }

                MouseArea {
                    id: loginButton
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.login(name.text, password.text, sessionIndex)
                }
            }

            // Error message
            Text {
                id: errorMessage
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
                color: nord11
                font.pixelSize: 13
                font.family: "JetBrains Mono, monospace"
                visible: text !== ""
                wrapMode: Text.WordWrap
                width: 320
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // Top bar with session and power options
    Rectangle {
        id: topBar
        anchors.top: parent.top
        width: parent.width
        height: 50
        color: Qt.rgba(1, 1, 1, 0.3)
        border.color: Qt.rgba(1, 1, 1, 0.2)
        border.width: 1

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 20
            spacing: 15

            // Session selector
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: textConstants.session
                    color: nord1
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    font.family: "JetBrains Mono, monospace"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 120
                    height: 32
                    color: Qt.rgba(1, 1, 1, 0.8)
                    border.color: Qt.rgba(76/255, 86/255, 106/255, 0.3)
                    border.width: 1
                    radius: 6

                    ComboBox {
                        id: session
                        anchors.fill: parent
                        anchors.margins: 1
                        color: "transparent"
                        textColor: nord0
                        borderColor: "transparent"
                        hoverColor: nord5
                        font.family: "JetBrains Mono, monospace"
                        font.pixelSize: 11
                        model: sessionModel
                        index: sessionModel.lastIndex
                        KeyNavigation.backtab: password
                        KeyNavigation.tab: layoutBox
                    }
                }
            }

            // Layout selector
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: textConstants.layout
                    color: nord1
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    font.family: "JetBrains Mono, monospace"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 60
                    height: 32
                    color: Qt.rgba(1, 1, 1, 0.8)
                    border.color: Qt.rgba(76/255, 86/255, 106/255, 0.3)
                    border.width: 1
                    radius: 6

                    LayoutBox {
                        id: layoutBox
                        anchors.fill: parent
                        anchors.margins: 1
                        color: "transparent"
                        textColor: nord0
                        borderColor: "transparent"
                        hoverColor: nord5
                        font.family: "JetBrains Mono, monospace"
                        font.pixelSize: 11
                        KeyNavigation.backtab: session
                        KeyNavigation.tab: shutdownButton
                    }
                }
            }
        }

        // Centered date and time
        Text {
            id: clock
            anchors.centerIn: parent
            color: nord1
            font.family: "JetBrains Mono, monospace"
            font.pixelSize: 14
            font.weight: Font.Medium
            text: Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm")
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm")
            }
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 20
            spacing: 15
            Rectangle {
                id: rebootButton
                width: 36
                height: 36
                color: rebootMouseArea.pressed ? nord12 : (rebootMouseArea.containsMouse ? Qt.rgba(208/255, 135/255, 112/255, 0.2) : Qt.rgba(1, 1, 1, 0.6))
                radius: 18
                border.color: rebootMouseArea.containsMouse ? nord12 : Qt.rgba(76/255, 86/255, 106/255, 0.3)
                border.width: 2

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "↻"
                    color: rebootMouseArea.containsMouse ? nord12 : nord1
                    font.pixelSize: 16
                    font.weight: Font.Normal
                }

                MouseArea {
                    id: rebootMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.reboot()
                }

                KeyNavigation.backtab: layoutBox
                KeyNavigation.tab: shutdownButton
            }

            // Shutdown button
            Rectangle {
                id: shutdownButton
                width: 36
                height: 36
                color: shutdownMouseArea.pressed ? nord11 : (shutdownMouseArea.containsMouse ? Qt.rgba(191/255, 97/255, 106/255, 0.2) : Qt.rgba(1, 1, 1, 0.6))
                radius: 18
                border.color: shutdownMouseArea.containsMouse ? nord11 : Qt.rgba(76/255, 86/255, 106/255, 0.3)
                border.width: 2

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "⏻"
                    color: shutdownMouseArea.containsMouse ? nord11 : nord1
                    font.pixelSize: 16
                    font.weight: Font.Normal
                }

                MouseArea {
                    id: shutdownMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.powerOff()
                }

                KeyNavigation.backtab: rebootButton
                KeyNavigation.tab: name
            }
        }
    }

    Component.onCompleted: {
        if (name.text === "")
            name.focus = true
        else
            password.focus = true
    }
}
