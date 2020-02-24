import Cocoa
import SwiftUI

// git log --format="%h %s"

struct Commit {
    let title : String
    let sha1 : String
}

var commits: [Commit] = []

func shell(_ argument: String) -> [String.SubSequence]
{
    let launchPath = "/usr/bin/env"
    let arguments = ["sh", "-c", argument]
    let task = Process()
    task.currentDirectoryPath = "/Users/\(NSUserName())/Projects/Supernaut"
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)

    return output!.split(separator: "\n")
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    var window: NSWindow!
    var statusBarNext : NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var statusBarItem : NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var statusBarPrev : NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var menu: NSMenu = NSMenu()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = shell("git reset HEAD --hard")
        let _ = shell("git clean -d -f")
        let _ = shell("git checkout master")

        for line in shell(#"git log --format="%h %s""#).reversed().dropFirst() {
            let components = line.split(separator: " ", maxSplits: 1)
            let (sha1, title) = (components[0], components[1])
            commits.append(Commit(title: String(title), sha1: String(sha1)))
        }
        
        statusBarPrev.button?.title = "◀︎"
        statusBarNext.button?.title = "▶︎"


        statusBarItem.button?.title = "🤟"
        statusBarItem.menu = menu
        menu.delegate = self
        self.update()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    func update() {
        self.menu.removeAllItems()

        for commit in commits {
            let menuItem = NSMenuItem(title: "\(commit.title)", action: #selector(goTo), keyEquivalent: "")
            menuItem.representedObject = commit as AnyObject
            menu.addItem(menuItem)
        }
        self.menu.addItem(NSMenuItem.separator())
        self.menu.addItem(NSMenuItem.init(title: "Quit", action: #selector(self.quit), keyEquivalent: ""))
    }
    
    @objc
    func goTo(sender: NSMenuItem) {
        let commit = sender.representedObject as! Commit
        // NSWorkspace.shared.open(URL(string: pr.url)!)
        let _ = shell("git reset HEAD --hard")
        let _ = shell("git clean -d -f")
        let _ = shell("git checkout \(commit.sha1)")
        let _ = shell("git reset HEAD~")
    }
    
    @objc
    func quit() {
        NSApplication.shared.terminate(self)
    }
}

