//
//  DragController.swift
//  CXLibTool
//
//  Created by abelchen on 2018/8/8.
//  Copyright © 2018年 com.tencent.abelchen. All rights reserved.
//

import Cocoa

protocol DragFileProtocol: class {
    func fileDraggedIn(fileURL: URL) -> Void
}

class DragView: NSTextField {
    
    weak var dragDelegate: DragFileProtocol?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    deinit {
        self.unregisterDraggedTypes()
    }
    
    var isDragingOver: Bool = false {
        didSet {
            var color = NSColor.gray
            if(isDragingOver){
                color = NSColor.systemBlue
            }
            layer?.borderColor = color.cgColor
            textColor = color
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isDragingOver = true
        return NSDragOperation.every
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDragingOver = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isDragingOver = false
        guard let path = NSURL(from: sender.draggingPasteboard())?.filePathURL else {
            return false
        }
        dragDelegate?.fileDraggedIn(fileURL: path)
        return true
    }
    
}

class DragController: NSViewController, DragFileProtocol {

    @IBOutlet weak var dragArea: DragView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dragArea.wantsLayer = true
        dragArea.layer?.borderWidth = 2
        dragArea.isDragingOver = false
        dragArea.dragDelegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func fileDraggedIn(fileURL: URL) {
        guard let windowController = storyboard?.instantiateController(withIdentifier:NSStoryboard.SceneIdentifier(rawValue: "detailWindow")) as? NSWindowController else {
            return
        }
        if let controller = windowController.contentViewController as? DetailController {
            controller.fileURL = fileURL
            windowController.showWindow(self)
        }
    }
}

