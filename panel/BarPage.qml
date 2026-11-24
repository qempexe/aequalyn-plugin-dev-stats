import QtQuick
import QtQuick.Layouts
import "root:/settings/center"

CcPage {
    id: page
    required property var svc
    title: "On the bar"
    sub: "The last days, as squares. Where they stand is in the control center, under Bar."

    CcSection {
        title: "Squares"
        Toggle { svc: page.svc; key: "showIcon"; title: "Platform icon"; sub: "GitHub's or GitLab's, before the squares." }
        Amount { svc: page.svc; key: "days"; title: "Days" }
        Amount { svc: page.svc; key: "squareSize"; title: "Size"; unit: " px" }
        Amount { svc: page.svc; key: "squareRound"; title: "Roundness"; unit: " px" }
    }
    CcSection {
        title: "Left click"
        CcChoice {
            options: [{ key: "panel", label: "Open the panel" }, { key: "refresh", label: "Refresh" }, { key: "none", label: "Nothing" }]
            current: page.svc.cfg.clickAction
            onChosen: k => page.svc.setValue("clickAction", k)
        }
    }
    CcSection {
        title: "Middle click"
        CcChoice {
            options: [{ key: "refresh", label: "Refresh" }, { key: "panel", label: "Open the panel" }, { key: "none", label: "Nothing" }]
            current: page.svc.cfg.middleAction
            onChosen: k => page.svc.setValue("middleAction", k)
        }
    }
    CcNote { text: "Right click always opens these settings." }
}
