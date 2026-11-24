// An amount of the plugin's settings, by its key.
import "root:/settings/center"
import "../js/Schema.js" as Schema

CcSlider {
    id: a
    required property var svc
    required property string key
    value: svc.cfg[key]
    from: Schema.items[key].min
    to: Schema.items[key].max
    step: Schema.items[key].step
    onCommitted: v => a.svc.setValue(a.key, v)
}
