// The panel as a window you can move, resize and tile.
import QtQuick
import Quickshell

FloatingWindow {
    id: win
    required property var svc
    title: "Dev stats"
    visible: true
    color: "transparent"
    implicitWidth: svc.cfg.windowWidth
    implicitHeight: svc.cfg.windowHeight
    PanelView { anchors.fill: parent; svc: win.svc }
}
