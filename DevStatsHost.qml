pragma Singleton
import QtQuick

// The plugin while it runs, for the rest of the shell; null while it is off.
QtObject {
    property var svc: null
}
