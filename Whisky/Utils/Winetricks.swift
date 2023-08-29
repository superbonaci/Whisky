//
//  Winetricks.swift
//  Whisky
//
//  Created by Isaac Marovitz on 12/07/2023.
//

import Foundation
import AppKit
import WhiskyKit

class Winetricks {
    static let winetricksURL: URL = GPTKInstaller.libraryFolder
        .appending(path: "winetricks")

    static func runCommand(command: String, bottle: Bottle) async {
        // swiftlint:disable:next line_length
        let winetricksCmd = #"PATH=\"\#(Wine.binFolder.path):$PATH\" WINE=wine64 WINEPREFIX=\"\#(bottle.url.path)\" \"\#(winetricksURL.path(percentEncoded: false))\" \#(command)"#

        let script = """
        tell application "Terminal"
            activate
            do script "\(winetricksCmd)"
        end tell
        """

        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)

            if let error = error {
                print(error)
                if let description = error["NSAppleScriptErrorMessage"] as? String {
                    await MainActor.run {
                        let alert = NSAlert()
                        alert.messageText = String(localized: "alert.message")
                        alert.informativeText = String(localized: "alert.info")
                            + " \(command): "
                            + description
                        alert.alertStyle = .critical
                        alert.addButton(withTitle: String(localized: "button.ok"))
                        alert.runModal()
                    }
                }
            }
        }
    }
}
