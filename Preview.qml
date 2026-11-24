// What the Store shows: the grid with made up days. Draws, and does nothing else.
import QtQuick
import "js/Stats.js" as Stats

Item {
    id: preview
    property var theme: null
    width: 360
    height: 220
    readonly property var days: {
        const out = {};
        const d = new Date(2026, 10, 1, 12);
        for (let i = 0; i < 364; i++) {
            const n = (i * 7 + (i % 11) * 5 + (i % 4) * 3) % 13;
            out[Stats.iso(d)] = n > 5 ? n - 5 : 0;
            d.setDate(d.getDate() - 1);
        }
        return out;
    }
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: preview.theme ? preview.theme.bgBase : "#141414"
        clip: true
        YearGrid {
            anchors.centerIn: parent
            theme: preview.theme
            cell: 4
            gap: 2
            model: Stats.buildGrid(preview.days, new Date(2026, 10, 1, 12), 0)
        }
    }
}
