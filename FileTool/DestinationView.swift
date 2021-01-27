//
//  DestinationView.swift
//  FileTool
//
//  Created by Murphy on 2021/1/26.
//  Copyright © 2021 Lenovo. All rights reserved.
//

import Cocoa

protocol DestinationViewDelegate {
    func processURLs(_ urls:[URL])
}

class DestinationView: NSView {
    
    enum Appearance {
        static let lineWidth: CGFloat = 10.0
    }
    
    override func awakeFromNib() {
        setup()
    }
    var delegate: DestinationViewDelegate?

    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if (isReceivingDrag) {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = Appearance.lineWidth
            path.stroke()

        }
        // Drawing code here.
    }

    func setup() {
        registerForDraggedTypes([NSPasteboard.PasteboardType.string,NSPasteboard.PasteboardType.URL,NSPasteboard.PasteboardType.fileURL])
    }

    func shouldAllowDrag(dragInfo:NSDraggingInfo) -> Bool {
        return true
    }
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isReceivingDrag = true
        return .copy
    }
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:nil) as? [URL], urls.count > 0 {
            delegate?.processURLs(urls)
            return true
        }
        return false
    }
}
