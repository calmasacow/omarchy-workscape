import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  readonly property var barWindow: root.QsWindow.window
  readonly property string screenName: barWindow && barWindow.screen ? barWindow.screen.name : ""
  property var workscapeConfig: ({})

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/workscape/config.json"
    watchChanges: true
    printErrors: false
    onLoaded: {
      try { root.workscapeConfig = JSON.parse(text()) }
      catch (e) { root.workscapeConfig = ({}) }
    }
    onLoadFailed: root.workscapeConfig = ({})
    onFileChanged: reload()
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = []
    var cfg = root.workscapeConfig
    var profiles = cfg.profiles || []
    var profile = null
    for (var p = 0; p < profiles.length; p++) {
      if (profiles[p].id === (cfg.settings || {}).activeProfileId) profile = profiles[p]
    }
    if (profile && profile.workspaceMonitors) {
      var savedMonitors = cfg.monitors || []
      var disabled = profile.disabledMonitors || []
      for (var ws in profile.workspaceMonitors) {
        var mid = profile.workspaceMonitors[ws]
        if (disabled.indexOf(mid) !== -1) continue
        for (var m = 0; m < savedMonitors.length; m++) {
          if (savedMonitors[m].id === mid && savedMonitors[m].name === root.screenName) {
            var number = Number(ws)
            if (number >= 1 && number <= 10 && ids.indexOf(number) === -1) ids.push(number)
          }
        }
      }
      ids.sort(function(left, right) { return left - right })
      return ids
    }
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      var id = workspace.id
      if (id > 0 && id <= 10 && workspace.monitor && workspace.monitor.name === root.screenName && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : Math.max(1, root.workspaceIds().length)
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
