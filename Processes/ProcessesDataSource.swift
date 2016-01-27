//
//  ProcessesDataSource.swift
//  Processes
//
//  Created by Stephen Sykes on 25/01/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

import Cocoa

class ProcessesDataSource: NSObject, NSTableViewDataSource {
    internal var pids : Array<Int>

    override init() {
        self.pids = []
        super.init()
    }

    @objc func update(allProcesses: Bool) {
        let cpids = fetchProcesses(allProcesses)
        if cpids == nil {
            NSLog("Malloc failed, that's fatal")
            NSApplication.sharedApplication().terminate(self)
        }

        var index: Int
        var newPids : Array<Int> = []
        for index = 0;;index++ {
            let pid = (cpids + index).memory
            if pid == 0 {
                break
            }
            newPids.append(Int(pid))
        }
        free(cpids)
        newPids.sortInPlace {
            return $1 < $0
        }
        pids = newPids
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return pids.count
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let pid = pids[row]
        if tableColumn!.title == "PID" {
            return String(pid)
        } else if tableColumn!.title == "Name" {
            let cstr = nameForProcess(Int32(pid))
            if cstr == nil {
                NSLog("Malloc failed, that's fatal")
                NSApplication.sharedApplication().terminate(self)
            }
            let str = String.fromCString(cstr)
            free(cstr)
            return str
        } else if tableColumn!.title == "Owner" {
            let cstr = ownerForProcess(Int32(pid))
            return String.fromCString(cstr)
        }
        return nil
    }

}
