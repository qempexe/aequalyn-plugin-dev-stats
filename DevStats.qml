// Dev stats: the contributions of your GitHub and GitLab accounts, through the logins the
// gh and glab commands already have. Called up by a key (qs ipc call dev-stats toggle):
// the arrows move over the days, Page Up and Page Down change the year, Tab the account,
// R fetches again, Esc closes. Nothing runs while it is closed.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "js/Stats.js" as Stats

Item {
    id: root
    property var theme: null
    property bool open: false
    property var accounts: []
    property int account: 0
    property int year: 0                         // 0: the last twelve months
    property var results: ({})                   // by Stats.resultKey
    property bool listed: false
    readonly property var now: accounts[account] || null
    readonly property string key: now ? Stats.resultKey(now, year) : ""
    readonly property var result: key !== "" ? results[key] || null : null
    readonly property var grid: result && result.days ? Stats.buildGrid(result.days, new Date(), year) : null
    readonly property var years: [0].concat(result && result.years ? result.years : [])
    readonly property string helper: decodeURIComponent(String(Qt.resolvedUrl("bin/dev-stats.sh")).replace(/^file:\/\//, ""))
    readonly property color cBg: theme ? theme.bgBase : "#141414"
    readonly property color cLine: theme ? theme.bgBorder : "#333333"
    readonly property color cText: theme ? theme.textPrimary : "#e0e0e0"
    readonly property color cMuted: theme ? theme.textMuted : "#8a8a8a"
    readonly property color cAccent: theme ? theme.accentPrimary : "#7aa2f7"

    function load(again) {
        if (!root.listed) { if (!lister.running) lister.running = true; return; }
        if (!root.now || fetcher.running || (root.result && !again)) return;
        fetcher.forKey = root.key;
        fetcher.command = [root.helper, "fetch", root.now.provider, root.now.host, root.now.user].concat(root.year > 0 ? [String(root.year)] : []);
        fetcher.running = true;
    }
    function keep(key, r) {
        const all = Object.assign({}, root.results);
        all[key] = r;
        root.results = all;
    }
    function stepYear(d) {
        const i = root.years.indexOf(root.year);
        root.year = root.years[Math.max(0, Math.min(root.years.length - 1, i + d))];
    }
    onOpenChanged: if (open) load(false)
    onKeyChanged: { view.picked = -1; if (open) load(false); }

    Process {
        id: lister
        command: [root.helper, "list"]
        stdout: StdioCollector { onStreamFinished: { root.accounts = Stats.parseAccounts(text); root.listed = true; root.load(false); } }
    }
    Process {
        id: fetcher
        property string forKey: ""
        stdout: StdioCollector { onStreamFinished: root.keep(fetcher.forKey, Stats.parseResult(text)) }
        onExited: if (root.open && root.key !== fetcher.forKey) root.load(false)
    }

    PanelWindow {
        visible: root.open
        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "aequalyn_panel_dev-stats"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        MouseArea { anchors.fill: parent; onClicked: root.open = false }
        Rectangle {
            anchors.centerIn: parent
            width: view.implicitWidth + 48
            height: body.implicitHeight + 40
            radius: 16
            color: root.cBg
            border.width: 1
            border.color: root.cLine
            focus: root.open
            Keys.onPressed: event => {
                const n = root.grid ? root.grid.flat.length : 0;
                const move = d => { view.picked = n === 0 ? -1 : Math.max(0, Math.min(n - 1, (view.picked < 0 ? n - 1 : view.picked + d))); };
                if (event.key === Qt.Key_Escape) root.open = false;
                else if (event.key === Qt.Key_Left) move(-7);
                else if (event.key === Qt.Key_Right) move(7);
                else if (event.key === Qt.Key_Up) move(-1);
                else if (event.key === Qt.Key_Down) move(1);
                else if (event.key === Qt.Key_PageUp) root.stepYear(1);
                else if (event.key === Qt.Key_PageDown) root.stepYear(-1);
                else if (event.key === Qt.Key_Tab && root.accounts.length > 0) root.account = (root.account + 1) % root.accounts.length;
                else if (event.key === Qt.Key_R) root.load(true);
                else return;
                event.accepted = true;
            }
            MouseArea { anchors.fill: parent }
            ColumnLayout {
                id: body
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12
                RowLayout {
                    spacing: 8
                    Text {
                        text: root.now ? Stats.providerGlyph(root.now.provider) + "  " + root.now.user : "Dev stats"
                        color: root.cAccent
                        font.pixelSize: 15
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.year > 0 ? String(root.year) : "Last 12 months"
                        color: root.cMuted
                        font.pixelSize: 12
                    }
                }
                YearGrid { id: view; theme: root.theme; model: root.grid }
                Text {
                    Layout.fillWidth: true
                    text: {
                        if (root.listed && !root.now) return "No account yet: log in with gh auth login or glab auth login.";
                        if (root.result && root.result.error) return Stats.errorText(root.result.error);
                        if (!root.grid) return "Reading your contributions…";
                        const on = view.hovered !== "" ? root.grid.flat.find(c => c.date === view.hovered) : view.pickedCell;
                        return on ? Stats.describe(on) : Stats.summaryLine(root.grid);
                    }
                    color: root.cText
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
                Text {
                    text: "← ↑ ↓ → day    PgUp PgDn year    Tab account    R refresh    Esc close"
                    color: root.cMuted
                    font.pixelSize: 11
                }
            }
        }
    }

    IpcHandler {
        target: "dev-stats"
        function toggle(): void { root.open = !root.open }
        function open(): void { root.open = true }
        function close(): void { root.open = false }
        function status(): string { return JSON.stringify({ open: root.open, accounts: root.accounts.length, total: root.grid ? root.grid.total : -1 }) }
    }
    Component.onCompleted: DevStatsHost.svc = root
    Component.onDestruction: if (DevStatsHost.svc === root) DevStatsHost.svc = null
}
