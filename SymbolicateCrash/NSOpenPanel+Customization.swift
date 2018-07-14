import Cocoa

extension NSOpenPanel {

    static func make(message: String? = "",
                     canChooseDirectories: Bool = false,
                     allowedFileTypes: [String]? = nil) -> NSOpenPanel {

        let panel = NSOpenPanel()
        panel.message = message
        panel.canChooseDirectories = canChooseDirectories
        panel.allowedFileTypes = allowedFileTypes
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false

        return panel
    }

}
