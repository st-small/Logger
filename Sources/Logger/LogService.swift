import Foundation

public protocol LogProvider {
    func log(_ event: LogEvent, message: String, file: String, function: String, line: Int)
}

public final class LogService {
    
    private static var providers = [LogProvider]()
    
    public static let shared = LogService(providers: providers)
    
    private init(providers: [LogProvider]) {
        LogService.providers = providers
    }
    
    public static func register(provider: LogProvider) {
        providers.append(provider)
    }
    
    public func info(_ object: Any, filename: String = #file, funcName: String = #function, line: Int = #line) {
        LogService.providers.forEach {
            $0.log(.info, message: ("\(object)"), file: LogService.fileName(filePath: filename), function: funcName, line: line)
        }
    }
    
    public func debug(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        LogService.providers.forEach {
            $0.log(.debug, message: ("\(object)"), file: LogService.fileName(filePath: filename), function: funcName, line: line)
        }
    }
    
    public func verbose(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        LogService.providers.forEach {
            $0.log(.verbose, message: ("\(object)"), file: LogService.fileName(filePath: filename), function: funcName, line: line)
        }
    }
    
    public func warning(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        LogService.providers.forEach {
            $0.log(.warning, message: ("\(object)"), file: LogService.fileName(filePath: filename), function: funcName, line: line)
        }
    }
    
    public func error(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        LogService.providers.forEach {
            $0.log(.error, message: ("\(object)"), file: LogService.fileName(filePath: filename), function: funcName, line: line)
        }
    }
    
    private static func fileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

public protocol FileWriter {
    func write(_ message: String)
}

public struct FileLogProvider: LogProvider {
    
    private var fileWriter: FileWriter
    
    public init(fileWriter: FileWriter) {
        self.fileWriter = fileWriter
    }
    
    public func log(_ event: LogEvent, message: String, file: String, function: String, line: Int) {
        fileWriter.write("[\(event.rawValue) \(Date().timeIntervalSince1970) \(file):\(function):\(line)] \(message)")
    }
}

public final class LogFileWriter: FileWriter {
    
    private var filePath: String
    private var fileHandle: FileHandle?
    private var queue: DispatchQueue
    
    init(filePath: String) {
        self.filePath = filePath
        self.queue = DispatchQueue(label: "Log File")
    }
    
    deinit {
        fileHandle?.closeFile()
    }
    
    public func write(_ message: String) {
        queue.sync(execute: { [weak self] in
            if let file = self?.getFileHandle() {
                let printed = message + "\n"
                if let data = printed.data(using: String.Encoding.utf8) {
                    file.seekToEndOfFile()
                    file.write(data)
                }
            }
        })
    }
    
    private func getFileHandle() -> FileHandle? {
        if fileHandle == nil {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: filePath) {
                fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
            }
            fileHandle = FileHandle(forWritingAtPath: filePath)
        }
        return fileHandle
    }
}
