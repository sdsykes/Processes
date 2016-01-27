//
//  AppDelegate.swift
//  Processes
//
//  Created by Stephen Sykes on 22/01/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

import Cocoa

let kAllProcesses = "allProcesses"
let kAllProcessesNotifcationName = "com.switchstep.allProcessesNotification"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var allIndicator: NSButton!
    @IBOutlet weak var dataSource : ProcessesDataSource!
    var updateTimer : NSTimer!
    var allProcesses : Bool = false

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let defaults = NSUserDefaults.standardUserDefaults()
        allProcesses = defaults.boolForKey(kAllProcesses)
        updateIndicator()

        updateTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "reloadTableData", userInfo: nil, repeats: true)

        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: "defaultChanged:", name: kAllProcessesNotifcationName, object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    // See the window by clicking the icon if it was closed
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        self.window.makeKeyAndOrderFront(self)
        return false
    }

    func updateIndicator() {
        if let cell = allIndicator.cell as? NSButtonCell {
            if allProcesses {
                cell.backgroundColor = NSColor.orangeColor()
                allIndicator.title = "ALL"
            } else {
                cell.backgroundColor = NSColor.greenColor()
                allIndicator.title = "OWN"
            }
        }
    }

    func defaultChanged(note: NSNotification) {
        // Tried to get the info via the prefs, but synchronize is not really effective as far as I can tell.
        // There is a notification you can get also, might be worth a try.
        // let defaults = NSUserDefaults.standardUserDefaults()
        // defaults.synchronize()
        if let setting : String = note.object as? String {
            if setting == "YES" {
                allProcesses = true
            } else {
                allProcesses = false
            }

            updateIndicator()
            reloadTableData()
        }
    }

    // When reloading the table be careful to move the selected row if needed
    // This can prevent accidents :)
    func reloadTableData() {
        let row = table.selectedRow
        var selectedPid : Int32 = 0
        if row >= 0 {
            selectedPid = Int32(dataSource.pids[row])
        }
        dataSource.update(allProcesses)
        table.reloadData()
        table.deselectAll(self)
        for r in 0..<table.numberOfRows {
            if Int32(dataSource.pids[r]) == selectedPid {
                table.selectRowIndexes(NSIndexSet(index: r), byExtendingSelection: false)
            }
        }
    }

    @IBAction func kill(button: NSButton) {
        let row = table.selectedRow
        if row < 0 {
            showAlert("Must select a process", info: "Choose a process to kill if you please")
            return
        }

        let pid = Int32(dataSource.pids[row])

        let result = killProc(pid, 0)
        if result == 0 {
            // it's ok, we can send the signal
            let result = killProc(pid, 9)
            if result != 0 {
                showAlert("Error killing owned process", info:"Maybe it died already")
            }
        } else {
            let authKillResult = Auth.authAndKill(pid)
            if !authKillResult {
                showAlert("Error killing non-owned process", info:"Did you authorize correctly?")
            }
        }
    }

    func showAlert(msg: String, info: String) {
        let alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = info
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.addButtonWithTitle("OK")
        alert.runModal()
    }

}
