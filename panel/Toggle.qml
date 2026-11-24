// A switch of the plugin's settings, by its key.
import "root:/settings/center"

CcToggle {
    id: t
    required property var svc
    required property string key
    checked: svc.cfg[key] === true
    onToggled: v => t.svc.setValue(t.key, v)
}
