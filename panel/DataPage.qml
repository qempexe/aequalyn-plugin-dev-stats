import QtQuick
import QtQuick.Layouts
import "root:/settings/center"

CcPage {
    id: page
    required property var svc
    property bool sure: false
    title: "Panel and data"
    sub: "How it opens, and how often it asks."

    CcSection {
        title: "Opens as"
        CcChoice {
            options: [{ key: "panel", label: "Under the bar" }, { key: "window", label: "Its own window" }]
            current: page.svc.cfg.openAs
            onChosen: k => page.svc.setValue("openAs", k)
        }
    }
    CcSection {
        title: "Size"
        Amount { svc: page.svc; key: "windowWidth"; title: "Width"; unit: " px" }
        Amount { svc: page.svc; key: "windowHeight"; title: "Height"; unit: " px" }
    }
    CcSection {
        title: "Data"
        Toggle { svc: page.svc; key: "autoRefresh"; title: "Refresh by itself"; sub: "Your own gh and glab are asked in the background." }
        Amount { svc: page.svc; key: "refreshMinutes"; title: "Every"; unit: " min"; enabled: page.svc.cfg.autoRefresh }
    }
    CcSection {
        title: "Start over"
        CcRow {
            title: "Every setting as it came"
            sub: "Your accounts stay."
            action: page.sure ? "Really reset?" : "Reset"
            onActivated: {
                if (page.sure) page.svc.resetSettings()
                page.sure = !page.sure
            }
        }
    }
}
