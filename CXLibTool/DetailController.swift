//
//  DetailController.swift
//  CXLibTool
//
//  Created by abelchen on 2018/8/8.
//  Copyright © 2018年 com.tencent.abelchen. All rights reserved.
//

import Cocoa

class DetailController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var archListView: NSTableView!
    @IBOutlet weak var objectListView: NSTableView!
    
    var fileURL: URL? {
        didSet {
            if fileURL != nil {
                loadFile(fileURL: fileURL!)
            }
        }
    }
    
    var isFat = false
    
    var archList = [String]()
    var objectList = [String]()
    
    override func viewDidAppear() {
        
    }
    
    func loadFile(fileURL: URL) {
        self.title = fileURL.path
        archList = [String]()
        objectList = [String]()
        let archsRes = fileArchitectures(fileURL: fileURL)
        if let archs = archsRes as? [String] {
            isFat = true
            let res = unArchiveFile(fileURL: fileURL, archs: archs)
            if !res {
                onError(msg: "库文件操作失败", close: true)
                return
            }
            archList.append(contentsOf: archs)
        }else if let arch = archsRes as? String {
            isFat = false
            archList.append(arch)
        }else{
            onError(msg: "库文件操作失败", close: true)
            return
        }
        archListView.reloadData()
        objectListView.reloadData()
    }
    
    func onError(msg:String, close:Bool) -> Void {
        let alert = NSAlert()
        alert.messageText = msg
        alert.addButton(withTitle:"确定")
        alert.alertStyle = NSAlert.Style.warning
        DispatchQueue.main.async {
            guard let window = self.view.window else {
                return
            }
            alert.beginSheetModal(for: window) { (_) in
                if close {
                    window.close()
                }
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == archListView {
            return archList.count
        }else if tableView == objectListView {
            return objectList.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == archListView {
            return archList[row]
        }else if tableView == objectListView {
            return objectList[row]
        }else{
            return ""
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if self.view.window?.firstResponder != archListView {
            return
        }
        if archListView.selectedRow == -1 {
            return
        }
        let arch = archList[archListView.selectedRow]
        guard let fileURL = self.fileURL else {
            return
        }
        if(isFat){
            objectList = objectsInFile(fileURL: fileURL, arch: arch)
        }else{
            objectList = objectsInFile(fileURL: fileURL)
        }
        objectListView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, didRemove rowView: NSTableRowView, forRow row: Int) {
        
    }
    
    override func keyDown(with event: NSEvent) {
        let keyCode = event.keyCode
        if keyCode != 51 {
            return
        }
        if self.view.window?.firstResponder == archListView {
            if archListView.selectedRow == -1 || archList.count <= 1 {
                return
            }
            guard let fileURL = self.fileURL else {
                return
            }
            archList.remove(at: archListView.selectedRow)
            let res = archiveFile(fileURL: fileURL, archs: archList)
            if !res {
                onError(msg: "库文件操作失败", close: true)
                return
            }
        }else if self.view.window?.firstResponder == objectListView {
            if objectListView.selectedRow == -1 || archListView.selectedRow == -1 {
                return
            }
            if(archList.count <= 1){
                onError(msg: "不允许删除最后一条", close: false)
                return
            }
            guard let fileURL = self.fileURL else {
                return
            }
            let objectSelected = objectList[objectListView.selectedRow]
            let arch = archList[archListView.selectedRow]
            var res = true
            if(isFat){
                res = removeObjectsInFile(fileURL: fileURL, arch: arch, object: objectSelected)
                if res {
                    res = archiveFile(fileURL: fileURL, archs: archList)
                }
            }else{
                res = removeObjectsInFile(fileURL: fileURL, object: objectSelected)
            }
            if !res {
                onError(msg: "库文件操作失败", close: true)
                return
            }
            objectList.remove(at: objectListView.selectedRow)
            objectListView.reloadData()
        }
    }
    
}
