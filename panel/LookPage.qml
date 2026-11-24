import QtQuick
import QtQuick.Layouts
import "root:/settings/center"
import "../js/Schema.js" as Schema

CcPage {
    id: page
    required property var svc
    title: "Look"
    sub: "The squares' colour, and what stands beside them. Everything else is your theme."

    CcSection {
        title: "Colour"
        Toggle { svc: page.svc; key: "gridFollow"; title: "Follow the theme"; sub: "The busiest days in your theme's accent." }
    }
    CcSection {
        visible: !page.svc.cfg.gridFollow
        title: "The busiest days"
        Row {
            spacing: 8
            Repeater {
                model: ["#39d353", "#58a6ff", "#bc8cff", "#ff6b2c", "#f85149", "#e3b341"]
                delegate: Rectangle {
                    id: dot
                    required property string modelData
                    width: 34; height: 34; radius: 8
                    color: dot.modelData
                    border.width: page.svc.cfg.gridColor === dot.modelData ? 2 : 0
                    border.color: Cc.theme.textPrimary
                    Accessible.role: Accessible.RadioButton
                    Accessible.name: dot.modelData
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.svc.setValue("gridColor", dot.modelData)
                    }
                }
            }
            CcField {
                id: hex
                inputWidth: 110
                placeholder: "#39d353"
                text: page.svc.cfg.gridColor
                onAccepted: {
                    if (Schema.isHex(text.trim())) page.svc.setValue("gridColor", text.trim().toLowerCase())
                    text = Qt.binding(() => page.svc.cfg.gridColor)
                }
            }
        }
    }
    CcSection {
        title: "Contributions page"
        Toggle { svc: page.svc; key: "showStreaks"; title: "Streaks"; sub: "The current and the longest one beside the total." }
        Toggle { svc: page.svc; key: "showLegend"; title: "Legend"; sub: "Less to More, under the squares." }
        Toggle { svc: page.svc; key: "showCards"; title: "Numbers"; sub: "The cards under the squares." }
    }
}
