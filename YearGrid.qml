// The year as squares, one a day, a column a week. Draws what Stats.buildGrid made.
import QtQuick

Item {
    id: grid
    property var theme: null
    property var model: null                     // Stats.buildGrid()
    property int cell: 11
    property int gap: 3
    property string hovered: ""
    property int picked: -1                      // the day the arrows are on (index in model.flat)
    readonly property color base: theme ? theme.accentPrimary : "#7aa2f7"
    property var colors: []                      // the four shades; without them, the theme's accent
    property string font: ""
    property color empty: theme ? theme.bgHover : "#2a2a2a"
    readonly property color ink: theme ? theme.textMuted : "#8a8a8a"
    readonly property var pickedCell: model && picked >= 0 ? model.flat[picked] || null : null
    implicitWidth: (model ? model.cols.length : 53) * (cell + gap) - gap
    implicitHeight: 16 + 7 * (cell + gap) - gap

    function shade(level) {
        return level <= 0 ? grid.empty : grid.colors.length === 4 ? grid.colors[level - 1] : Qt.rgba(grid.base.r, grid.base.g, grid.base.b, [0, 0.3, 0.5, 0.75, 1][level])
    }

    Repeater {
        model: grid.model ? grid.model.months : []
        delegate: Text {
            required property var modelData
            x: modelData.col * (grid.cell + grid.gap)
            text: modelData.label
            color: grid.ink
            font.family: grid.font !== "" ? grid.font : Qt.application.font.family
            font.pixelSize: 10
        }
    }
    Repeater {
        model: grid.model ? grid.model.cols : []
        delegate: Column {
            id: week
            required property var modelData
            required property int index
            x: week.index * (grid.cell + grid.gap)
            y: 16
            spacing: grid.gap
            Repeater {
                model: week.modelData
                delegate: Rectangle {
                    id: day
                    required property var modelData
                    width: grid.cell; height: grid.cell; radius: 3
                    color: day.modelData.skip ? "transparent" : grid.shade(day.modelData.level)
                    border.width: grid.pickedCell && grid.pickedCell.date === day.modelData.date ? 2 : 0
                    border.color: grid.theme ? grid.theme.textPrimary : "#ffffff"
                    MouseArea {
                        anchors.fill: parent
                        enabled: !day.modelData.skip
                        hoverEnabled: true
                        onEntered: grid.hovered = day.modelData.date
                        onExited: if (grid.hovered === day.modelData.date) grid.hovered = ""
                    }
                }
            }
        }
    }
}
