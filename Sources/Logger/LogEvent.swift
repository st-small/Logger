import Foundation

public enum LogEvent: String {
    case info = "ℹ️" // some information
    case debug = "📝" // something to debug
    case verbose = "📣" // debugging on steroids
    case warning = "⚠️" // not good, but not fatal
    case error = "☠️" // this is fatal
}
