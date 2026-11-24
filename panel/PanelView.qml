// The panel's inside, built as the control center is and from its own parts (Cc*): the
// title bar, the pages on the left, the page, the footer. Under the bar (BarWidget.qml) or
// in a window (PopoutWindow.qml).
import QtQuick
import "root:/settings/center"

Rectangle {
    id: view
    required property var svc
    readonly property var pages: [
        { key: "year", label: "Contributions", icon: "", file: "YearPage.qml" },
        { key: "look", label: "Look", icon: "", file: "LookPage.qml" },
        { key: "bar", label: "On the bar", icon: "", file: "BarPage.qml" },
        { key: "data", label: "Panel and data", icon: "", file: "DataPage.qml" }
    ]
    readonly property int at: Math.max(0, view.pages.findIndex(p => p.key === view.svc.page))
    function step(n) { view.svc.page = view.pages[(view.at + n + view.pages.length) % view.pages.length].key }

    radius: svc.popped ? 0 : 20
    color: Cc.theme.bgBase
    border.color: Cc.theme.bgBorder
    border.width: 1
    clip: true

    // ---- title bar ---------------------------------------------------------------
    Item {
        id: titleBar
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 60
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: view.svc.glyph
                color: Cc.theme.accentPrimary
                font.family: Cc.mono
                font.pixelSize: 22
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Dev stats"
                color: Cc.theme.textPrimary
                font.family: Cc.sans
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: view.svc.statusLine
                textFormat: Text.PlainText
                color: Cc.theme.textMuted
                font.family: Cc.sans
                font.pixelSize: 13
            }
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            CcButton {
                anchors.verticalCenter: parent.verticalCenter
                text: view.svc.busy ? "Updating…" : "Refresh"
                enabled: !view.svc.busy
                onClicked: view.svc.refresh()
            }
            CcButton {
                anchors.verticalCenter: parent.verticalCenter
                text: view.svc.popped ? "Dock" : "Pop out"
                onClicked: view.svc.popped ? view.svc.dock() : view.svc.popOut()
            }
            Rectangle {
                width: 34; height: 34; radius: 10
                color: closeArea.containsMouse ? Cc.theme.bgHover : "transparent"
                Accessible.role: Accessible.Button
                Accessible.name: "Close"
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: Cc.theme.textSecondary
                    font.family: Cc.sans
                    font.pixelSize: 14
                }
                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: view.svc.close()
                }
            }
        }
    }
    Rectangle { anchors.top: titleBar.bottom; width: parent.width; height: 1; color: Cc.theme.bgBorder }

    // ---- the pages ---------------------------------------------------------------
    Column {
        id: nav
        anchors { left: parent.left; top: titleBar.bottom; leftMargin: 10; topMargin: 12 }
        width: 156
        spacing: 2
        Repeater {
            model: view.pages
            delegate: Rectangle {
                id: navItem
                required property var modelData
                readonly property bool on: view.svc.page === modelData.key
                width: nav.width
                height: 38
                radius: 8
                color: on ? Cc.theme.bgSelected : navArea.containsMouse ? Cc.theme.bgSurface : "transparent"
                Accessible.role: Accessible.PageTab
                Accessible.name: modelData.label
                Rectangle {
                    visible: navItem.on
                    width: 3; height: 20; radius: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: Cc.theme.accentPrimary
                }
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        horizontalAlignment: Text.AlignHCenter
                        text: navItem.modelData.icon
                        color: Cc.theme.accentPrimary
                        font.family: Cc.mono
                        font.pixelSize: 14
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: navItem.modelData.label
                        color: navItem.on ? Cc.theme.textPrimary : Cc.theme.textSecondary
                        font.family: Cc.sans
                        font.pixelSize: 13
                        font.weight: navItem.on ? Font.DemiBold : Font.Normal
                    }
                }
                MouseArea {
                    id: navArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: view.svc.page = navItem.modelData.key
                }
            }
        }
    }
    Rectangle { id: line; anchors { left: nav.right; leftMargin: 10; top: titleBar.bottom; bottom: footer.top } width: 1; color: Cc.theme.bgBorder }

    Loader {
        id: pageLoader
        anchors { left: line.right; right: parent.right; top: titleBar.bottom; bottom: footer.top
                  leftMargin: 22; rightMargin: 10; topMargin: 18; bottomMargin: 8 }
        // (setSource hands the page its service before its bindings first run)
        readonly property string file: view.pages[view.at].file
        onFileChanged: setSource(Qt.resolvedUrl(file), { svc: view.svc })
        Component.onCompleted: setSource(Qt.resolvedUrl(file), { svc: view.svc })
    }

    // ---- footer ------------------------------------------------------------------
    Item {
        id: footer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 34
        Rectangle { width: parent.width; height: 1; color: Cc.theme.bgBorder }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: "pg up pg dn  pages     r  refresh     esc  close"
            color: Cc.theme.textMuted
            font.family: Cc.mono
            font.pixelSize: 10
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: view.svc.page === "year" ? view.svc.updatedText : "Changes are saved as you make them"
            color: Cc.theme.textMuted
            font.family: Cc.sans
            font.pixelSize: 11
        }
    }

    Shortcut { sequence: "PgDown"; onActivated: view.step(1) }
    Shortcut { sequence: "PgUp"; onActivated: view.step(-1) }
    Shortcut { sequence: "R"; onActivated: view.svc.refresh() }
    Shortcut { sequence: "Escape"; onActivated: view.svc.close() }
}
