import Cocoa

class FolderTextField: NSTextField {
    override init(frame: NSRect) {
        super.init(frame: frame)
        registerForDraggedTypes([.fileURL])
        formatter = MyURLFormatter()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
        drawsBackground = true
        formatter = MyURLFormatter()
    }

    override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        let dragPasteboard = sender.draggingPasteboard
        guard let types = dragPasteboard.types else {
            return []
        }
        guard types.contains(.fileURL) else {
            return []
        }
        guard sender.draggingSourceOperationMask.contains(.generic) else {
            return []
        }
        guard dragPasteboard.pasteboardItems?.count == 1 else {
            return []
        }
        guard let url = NSURL(from: dragPasteboard) as? URL else {
            return []
        }
        guard (try? url.checkResourceIsReachable()) == true else {
            return []
        }
        guard let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]) else {
            return []
        }
        guard values.isDirectory == true, values.isPackage == false else {
            return []
        }
        // passes all the tests! provide feedback and we're out of here
        backgroundColor = NSColor(calibratedRed: 1, green: 0.909, blue: 0.684, alpha: 1)
        return .copy
    }
    
    override func draggingExited(_ sender: (any NSDraggingInfo)?) {
        finished()
    }
    
    /// If we were editing, this is not called; the field editor just accepts the path, kaboom.
    /// Therefore we are not editable at all (simplest way out).
    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        defer {
            finished()
        }
        guard let url = NSURL(from: sender.draggingPasteboard) as? URL else {
            return false
        }
        self.objectValue = url
        sendAction(action, to: target) // we changed the value in code, we have to signal manually
        return true
    }

    func finished() {
        Task {
            backgroundColor = NSColor.white
        }
    }

    override func draw(_ rect: NSRect) {
        let context = NSGraphicsContext.current
        context?.saveGraphicsState()
        do {
            context?.shouldAntialias = true

            let bounds = self.bounds.insetBy(dx: 1, dy: 1)
            let path = NSBezierPath(roundedRect: bounds, xRadius: 5, yRadius: 5)
            path.setClip()

            if let bg = self.backgroundColor {
                bg.setFill()
                path.fill()
            }
        }
        context?.restoreGraphicsState()
        super.draw(rect)

    }
}
