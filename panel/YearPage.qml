// The year: whose and which, its squares, and what they add up to.
import QtQuick
import QtQuick.Layouts
import "root:/settings/center"
import ".."
import "../js/Stats.js" as Model

CcPage {
    id: page
    required property var svc
    readonly property var rolling: svc.current ? svc.results[Model.accountKey(svc.current)] || null : null
    readonly property var years: rolling && rolling.years ? rolling.years : []
    readonly property var result: svc.current ? svc.results[Model.resultKey(svc.current, svc.selectedYear)] || null : null
    readonly property bool hasData: !!result && result.error === undefined
    readonly property var grid: Model.buildGrid(hasData ? result.days : ({}), new Date(), svc.selectedYear)
    readonly property int active: grid.flat.filter(c => c.count > 0).length

    title: "Contributions"
    sub: !svc.current ? "Your own gh and glab, nothing else."
       : hasData ? Model.summaryLine(grid, svc.cfg.showStreaks) : "Waiting for " + svc.current.user

    CcSection {
        visible: !page.svc.current && !page.svc.busy
        title: "No account yet"
        CcRow { icon: ""; title: "GitHub"; sub: "gh auth login" }
        CcRow { icon: ""; title: "GitLab"; sub: "glab auth login" }
        CcNote { text: "Log in from a terminal, then press Refresh. Or list accounts in ~/.local/state/aequalyn-dev-stats/accounts.json." }
    }
    CcSegments {
        visible: page.svc.accounts.length > 1
        wrap: false
        options: page.svc.accounts.map((a, i) => ({ key: i, label: Model.providerLabel(a.provider) + " · " + a.user }))
        current: page.svc.selected
        onChosen: i => page.svc.selectAccount(i)
    }
    CcSegments {
        visible: page.years.length > 0
        wrap: false
        options: [{ key: 0, label: "Last year" }].concat(page.years.map(y => ({ key: y, label: String(y) })))
        current: page.svc.selectedYear
        onChosen: y => page.svc.selectYear(y)
    }
    Rectangle {
        visible: !!page.svc.current
        Layout.fillWidth: true
        implicitHeight: col.implicitHeight + 28
        radius: 6
        color: Cc.alpha(Cc.theme.textPrimary, 0.03)
        border.width: 1
        border.color: Cc.alpha(Cc.theme.textPrimary, 0.08)
        ColumnLayout {
            id: col
            x: 14; y: 14
            width: parent.width - 28
            spacing: 10
            YearGrid {
                id: squares
                Layout.alignment: Qt.AlignHCenter
                theme: Cc.theme
                colors: page.svc.palette
                empty: Cc.alpha(Cc.theme.textPrimary, 0.08)
                font: Cc.sans
                model: page.grid
                gap: 2
                cell: Math.max(6, Math.floor((col.width + gap) / Math.max(1, page.grid.cols.length)) - gap)
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    readonly property var day: squares.hovered === "" ? null : page.grid.flat.find(c => c.date === squares.hovered) || null
                    Layout.fillWidth: true
                    text: day ? (day.count === 0 ? "No contributions" : day.count + (day.count === 1 ? " contribution" : " contributions")) + "  ·  " + day.when
                        : page.result && page.result.error !== undefined ? Model.errorText(page.result.error)
                        : !page.hasData ? "Fetching…" : "Hover a day for its count"
                    color: Cc.theme.textMuted
                    opacity: day ? 1 : 0.65
                    font.family: Cc.sans
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
                Text { visible: page.svc.cfg.showLegend; text: "Less"; color: Cc.theme.textMuted; opacity: 0.65; font.family: Cc.sans; font.pixelSize: 10 }
                Repeater {
                    model: page.svc.cfg.showLegend ? [squares.empty].concat(page.svc.palette) : []
                    delegate: Rectangle { required property var modelData; width: 10; height: 10; radius: 3; color: modelData }
                }
                Text { visible: page.svc.cfg.showLegend; text: "More"; color: Cc.theme.textMuted; opacity: 0.65; font.family: Cc.sans; font.pixelSize: 10 }
            }
        }
    }
    RowLayout {
        visible: page.svc.cfg.showCards && page.hasData
        Layout.fillWidth: true
        spacing: 8
        Repeater {
            model: [
                { icon: "", name: "Contributions", value: String(page.grid.total) },
                { icon: "", name: "Active days", value: String(page.active) },
                { icon: "", name: page.grid.showCurrent ? "Streak, longest" : "Longest streak",
                  value: page.grid.showCurrent ? page.grid.current + ", " + page.grid.longest : String(page.grid.longest) },
                { icon: "", name: "Busiest day", value: page.grid.busiest ? page.grid.busiest.count + " on " + Model.shortDay(page.grid.busiest) : "none" }
            ]
            delegate: Rectangle {
                id: tile
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 62
                radius: 6
                color: Cc.alpha(Cc.theme.textPrimary, 0.04)
                border.width: 1
                border.color: Cc.alpha(Cc.theme.textPrimary, 0.08)
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    Text { text: tile.modelData.icon; color: Cc.theme.accentPrimary; font.family: Cc.mono; font.pixelSize: 16 }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { Layout.fillWidth: true; text: tile.modelData.value; color: Cc.theme.textPrimary; font.family: Cc.sans; font.pixelSize: 13; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { Layout.fillWidth: true; text: tile.modelData.name; color: Cc.theme.textMuted; opacity: 0.65; font.family: Cc.sans; font.pixelSize: 10; elide: Text.ElideRight }
                    }
                }
            }
        }
    }
}
