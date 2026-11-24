// Dev stats: the last days of your contributions as squares on the bar (BarWidget.qml), and
// the whole year in the panel that opens from it, or in a window of its own. This is the
// one service behind them all: the accounts and their results, refreshing, the settings
// and what the panel shows. The numbers come from bin/dev-stats.sh, which runs your own gh
// and glab.
import QtQuick
import Quickshell
import Quickshell.Io
import "core"
import "js/Stats.js" as Model
import "js/Schema.js" as Schema

Item {
    id: root
    property var theme: null
    property string page: "year"          // year | look | bar | data

    // ---- settings ------------------------------------------------------------------
    SettingsStore { id: settingsStore }
    readonly property color accent: theme ? theme.accentPrimary : "#7aa2f7"
    function hex(c) {
        const h = v => ("0" + Math.round(v * 255).toString(16)).slice(-2)
        return "#" + h(c.r) + h(c.g) + h(c.b)
    }
    readonly property var cfg: Schema.resolve(settingsStore.values)
    function setValue(key, value) { settingsStore.set(key, value) }
    function resetSettings() { settingsStore.reset() }
    // the busiest days: the theme's accent, or the Grid color of Settings
    readonly property string gridColor: cfg.gridFollow !== false ? root.hex(root.accent) : cfg.gridColor

    // ---- what the panel and the bar show -------------------------------------------
    property var accounts: []
    property var results: ({})
    property int selected: 0
    property int selectedYear: 0          // 0 = rolling last year
    property var yearReq: null            // pending on-demand year fetch
    property var yearRunning: null        // year fetch currently in flight
    property bool busy: false
    property real updatedAt: 0
    property int fetchIndex: 0
    readonly property string scriptPath: decodeURIComponent(
        String(Qt.resolvedUrl("bin/dev-stats.sh")).replace(/^file:\/\//, ""))
    readonly property var current: accounts.length > selected ? accounts[selected] : null
    readonly property string glyph: Model.providerGlyph(current ? current.provider : "github")
    readonly property string updatedText: busy ? "Updating…"
        : (updatedAt > 0 ? "Updated " + Qt.formatTime(new Date(updatedAt), "HH:mm") : "")
    readonly property string statusLine: (current
        ? Model.providerLabel(current.provider) + " · " + current.user
        : (busy ? "Looking for accounts" : "No account yet: gh auth login, or glab auth login"))
        + (updatedText !== "" ? "  ·  " + updatedText.toLowerCase() : "")

    // Newest `n` visible cells of the grid, oldest first.
    function lastDays(grid, n) {
        const out = []
        for (let c = grid.cols.length - 1; c >= 0 && out.length < n; c--)
            for (let r = 6; r >= 0 && out.length < n; r--)
                if (!grid.cols[c][r].skip) out.unshift(grid.cols[c][r])
        return out
    }
    readonly property var recent: {
        const res = current ? results[Model.accountKey(current)] : null
        const days = (res && !res.error) ? lastDays(Model.buildGrid(res.days, new Date()), cfg.days) : []
        while (days.length < cfg.days) days.unshift({ level: 0, count: 0 })
        return days
    }
    readonly property var palette: Model.palette(root.gridColor)

    // ---- refresh: list the accounts, then fetch each one in turn -------------------
    function refresh() {
        if (busy) return
        busy = true
        const keep = {}
        for (const k in results) if (k.split("|").length === 3) keep[k] = results[k]
        results = keep
        stuck.restart()
        listProc.running = true
    }
    function finish() {
        busy = false
        stuck.stop()
        updatedAt = Date.now()
        if (selectedYear > 0) selectYear(selectedYear)
    }
    function selectAccount(i) {
        selected = i
        selectedYear = 0
    }
    function selectYear(y) {
        selectedYear = y
        if (y > 0 && current && !results[Model.resultKey(current, y)]) {
            yearReq = { account: current, year: y }
            yearTimer.restart()
        }
    }
    function launchYear() {
        if (!yearReq) return
        if (yearProc.running) { yearTimer.restart(); return }
        yearRunning = yearReq
        yearReq = null
        const a = yearRunning.account
        yearProc.command = [scriptPath, "fetch", a.provider, a.host, a.user, String(yearRunning.year)]
        yearProc.running = true
    }
    function onYearFetched(text) {
        const q = yearRunning
        yearRunning = null
        if (q) keep(Model.resultKey(q.account, q.year), text)
        if (yearReq) yearTimer.restart()
    }
    function keep(key, text) {
        const next = Object.assign({}, results)
        next[key] = Model.parseResult(text)
        results = next
    }
    function fetchNext() {
        if (fetchProc.running) { stepTimer.restart(); return }
        if (fetchIndex >= accounts.length) { finish(); return }
        const a = accounts[fetchIndex]
        fetchProc.command = [scriptPath, "fetch", a.provider, a.host, a.user]
        fetchProc.running = true
    }
    function onAccounts(text) {
        accounts = Model.parseAccounts(text)
        if (selected >= accounts.length) selected = 0
        fetchIndex = 0
        stepTimer.restart()
    }
    function onFetched(text) {
        const a = accounts[fetchIndex]
        if (a) keep(Model.accountKey(a), text)
        fetchIndex++
        stepTimer.restart()
    }
    Process { id: listProc; command: [root.scriptPath, "list"]; stdout: StdioCollector { onStreamFinished: root.onAccounts(text) } }
    Process { id: fetchProc; stdout: StdioCollector { onStreamFinished: root.onFetched(text) } }
    Process { id: yearProc; stdout: StdioCollector { onStreamFinished: root.onYearFetched(text) } }
    Timer { id: yearTimer; interval: 60; onTriggered: root.launchYear() }
    // Lets a finished process fully exit before the next one is started.
    Timer { id: stepTimer; interval: 60; onTriggered: root.fetchNext() }
    // Never stay "busy" forever if a process failed to start.
    Timer { id: stuck; interval: 180000; onTriggered: root.busy = false }
    Timer {
        interval: root.cfg.refreshMinutes * 60 * 1000
        repeat: true
        running: root.cfg.autoRefresh
        onTriggered: root.refresh()
    }

    // ---- the panel: under the bar, or popped out as a window -----------------------
    property bool popped: false
    property bool userPicked: false       // Pop out or Dock was used: "Open as" no longer decides
    property bool windowRequested: false
    // the widget whose panel is open, if any (BarWidget.qml)
    readonly property var openWidget: DevStatsHost.widgets.find(w => w.panelOpen) || null

    readonly property bool opened: !!root.openWidget || root.windowRequested
    function popOut() { root.userPicked = true; root.popped = true; root.closePanels(); root.windowRequested = true }
    function dock() { root.userPicked = true; root.windowRequested = false; root.popped = false; Qt.callLater(root.openPanel) }
    function closePanels() { for (const w of DevStatsHost.widgets) w.closePanel() }
    function close() { root.closePanels(); root.windowRequested = false }
    // under a bar widget; without one on any bar, as a window
    function openPanel(widget) {
        const w = widget || DevStatsHost.widgets[0] || null
        if (w) w.openPanel(!widget)
        else { root.popped = true; root.windowRequested = true }
    }
    function open(widget) {
        if (!root.userPicked) root.popped = root.cfg.openAs === "window"
        if (root.popped) root.windowRequested = true
        else root.openPanel(widget)
    }
    function toggle(widget) {
        if (root.windowRequested || root.openWidget) root.close()
        else root.open(widget)
    }
    function showPage(name, widget) {
        root.page = name
        if (!root.opened) root.open(widget)
    }
    Loader {
        id: windowLoader
        readonly property bool want: root.windowRequested
        onWantChanged: want ? setSource(Qt.resolvedUrl("panel/PopoutWindow.qml"), { svc: root }) : source = ""
        Connections {
            target: windowLoader.item
            ignoreUnknownSignals: true
            function onVisibleChanged() {
                if (windowLoader.item && !windowLoader.item.visible) root.windowRequested = false
            }
        }
    }

    IpcHandler {
        target: "dev-stats"
        function toggle(): void { if (!root.opened) root.page = "year"; root.toggle(null) }
        function open(): void { root.open(null) }
        function close(): void { root.close() }
        function settings(): void { root.showPage("look", null) }
        function refresh(): void { root.refresh() }
        function status(): string {
            return JSON.stringify({ open: root.opened, page: root.page, accounts: root.accounts.length, widgets: DevStatsHost.widgets.length, busy: root.busy })
        }
    }
    Component.onCompleted: { DevStatsHost.svc = root; root.refresh() }
    Component.onDestruction: if (DevStatsHost.svc === root) DevStatsHost.svc = null
}
