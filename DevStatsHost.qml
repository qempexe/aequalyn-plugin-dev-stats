pragma Singleton
import QtQuick

// The plugin while it runs, for its bar widgets and the rest of the shell; null while it
// is off. `widgets`: the ones on the bars, one a screen.
QtObject {
    property var svc: null
    property var widgets: []
}
