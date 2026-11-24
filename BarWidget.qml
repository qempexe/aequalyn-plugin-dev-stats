// Dev stats on the bar: the last days as squares. Left click opens the panel under it,
// right click its settings, middle click refreshes (or what Settings says).
import QtQuick
import Quickshell
import "root:/settings"
import "root:/plugins/bar/quick"
import "panel"

Rectangle {
    id: widget
    required property var bar
    property color ink: "transparent"
    readonly property var svc: DevStatsHost.svc
    readonly property var cfg: svc ? svc.cfg : null
    readonly property bool wanted: !!svc
    readonly property bool panelOpen: popup.visible
    readonly property int square: cfg ? cfg.squareSize : 9
    readonly property int count: cfg ? cfg.days : 7

    objectName: "aequalyn-dev-stats"
    Accessible.role: Accessible.Button
    Accessible.name: "Dev stats: " + (svc ? svc.statusLine : "off")
    width: bar.vertical ? bar.chipAcross : content.implicitWidth + 16
    height: bar.vertical ? content.implicitHeight + 12 : 24
    radius: 8
    color: area.containsMouse || widget.panelOpen ? bar.theme.bgSelected : bar.chipColor

    Grid {
        id: content
        anchors.centerIn: parent
        columns: widget.bar.vertical ? 1 : widget.count + 1
        rowSpacing: 3
        columnSpacing: 2
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        Text {
            visible: !widget.cfg || widget.cfg.showIcon
            text: widget.svc ? widget.svc.glyph : ""
            color: widget.bar.inked(widget.ink, widget.bar.theme.accentPrimary)
            font.family: widget.bar.iconFont
            font.pixelSize: 13
            rightPadding: widget.bar.vertical ? 0 : 4
        }
        Repeater {
            model: widget.svc ? widget.svc.recent : []
            delegate: Rectangle {
                required property var modelData
                width: widget.square
                height: widget.square
                radius: Math.min(widget.square / 2, widget.cfg ? widget.cfg.squareRound : 2)
                color: modelData.level <= 0 || !widget.svc ? Qt.alpha(widget.bar.theme.textPrimary, 0.16)
                                                           : widget.svc.palette[modelData.level - 1]
            }
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
            if (!widget.svc) return
            const what = mouse.button === Qt.RightButton ? "settings"
                : mouse.button === Qt.MiddleButton ? widget.cfg.middleAction : widget.cfg.clickAction
            if (what === "settings") widget.svc.showPage("look", widget)
            else if (what === "panel") { if (!widget.svc.opened) widget.svc.page = "year"; widget.svc.toggle(widget) }
            else if (what === "refresh") widget.svc.refresh()
        }
    }

    // ---- its panel --------------------------------------------------------------------
    // one panel of the bar at a time, as the bar's own (Bar.qml: widgetPopup)
    readonly property bool wantOpen: bar.widgetPopup === "dev-stats" && !!widget.QsWindow.window
                                     && widget.QsWindow.window.screen === bar.popupScreen
    function openPanel(byKey) { if (!widget.wantOpen) widget.bar.toggleWidgetPopup("dev-stats", widget.QsWindow.window ? widget.QsWindow.window.screen : null, byKey === true) }
    function closePanel() { if (widget.wantOpen) widget.bar.widgetPopup = "" }

    PopupWindow {
        id: popup
        readonly property string side: ["bottom", "left", "right"].indexOf(AequalynSettings.barPosition) >= 0 ? AequalynSettings.barPosition : "top"
        readonly property bool sideways: side === "left" || side === "right"
        readonly property int openEdge: side === "bottom" ? Edges.Top : side === "left" ? Edges.Right : side === "right" ? Edges.Left : Edges.Bottom
        readonly property int room: widget.QsWindow.window && widget.QsWindow.window.screen ? widget.QsWindow.window.screen.height - 80 : 900
        visible: widget.wantOpen
        color: "transparent"
        // opened by a key or a command it may not take the keyboard (Quick.byKey)
        grabFocus: !Quick.byKey
        implicitWidth: widget.cfg ? widget.cfg.windowWidth : 860
        implicitHeight: Math.min(popup.room, widget.cfg ? widget.cfg.windowHeight : 560)
        // closed from outside (a click elsewhere): the bar is told, and `visible` follows again
        onVisibleChanged: if (!visible && widget.wantOpen) { widget.closePanel(); popup.visible = Qt.binding(() => widget.wantOpen) }
        anchor.item: widget
        anchor.rect.x: popup.side === "right" ? -8 : 0
        anchor.rect.y: popup.side === "bottom" ? -8 : 0
        anchor.rect.width: widget.width + (popup.sideways ? 8 : 0)
        anchor.rect.height: widget.height + (popup.sideways ? 0 : 8)
        anchor.edges: popup.openEdge
        anchor.gravity: popup.openEdge
        anchor.adjustment: PopupAdjustment.Slide

        Loader {
            id: view
            anchors.fill: parent
            active: widget.wantOpen && !!widget.svc
            sourceComponent: Component { PanelView { svc: widget.svc } }
        }
    }

    Component.onCompleted: DevStatsHost.widgets = DevStatsHost.widgets.concat([widget])
    Component.onDestruction: {
        DevStatsHost.widgets = DevStatsHost.widgets.filter(w => w !== widget)
        // turned off while open: not open again when it is back
        try { if (widget.bar.widgetPopup === "dev-stats") widget.bar.widgetPopup = "" } catch (e) {}
    }
}
