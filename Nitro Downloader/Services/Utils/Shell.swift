
// Shell.swift


import Foundation

@MainActor
class Shell {
    
    /// Runs a shell command and streams the standard output and standard error.
    /// This is ideal for long-running processes like installations where you want to show live progress.
    /// - Parameters:
    ///   - command: The full shell command to execute (e.g., "/bin/bash -c 'ls -l'").
    ///   - onOutput: A closure that receives live standard output lines.
    ///   - onError: A closure that receives live standard error lines.
    /// - Throws: `ShellError.commandFailed` if the process returns a non-zero exit code.
    func runWithStreamingOutput(
        _ command: String,
        onOutput: @escaping (String) -> Void,
        onError: @escaping (String) -> Void
    ) async throws {
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh") // Use zsh, the default macOS shell
        process.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Stream standard output
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let line = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !line.isEmpty {
                DispatchQueue.main.async { onOutput(line) }
            }
        }
        
        // Stream standard error
        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let line = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !line.isEmpty {
                DispatchQueue.main.async { onError(line) }
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { process in
                // Close the handlers
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil
                
                if process.terminationStatus == 0 {
                    continuation.resume(returning: ())
                } else {
                    // Even on failure, we let the onError handler provide the details.
                    // The error here signals the failure state.
                    continuation.resume(throwing: ShellError.commandFailed(
                        terminationStatus: process.terminationStatus,
                        errorOutput: "See installation log for details."
                    ))
                }
            }
            
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Runs a command and returns the entire standard output as a single string upon completion.
    /// Best for short commands like `brew --version`.
    /// - Parameter command: The command to run.
    /// - Returns: The captured standard output, trimmed of whitespace.
    /// - Throws: `ShellError.commandFailed` if the process fails.
    func run(_ command: String) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        if process.terminationStatus == 0 {
            return String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        } else {
            let errorString = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown error"
            throw ShellError.commandFailed(terminationStatus: process.terminationStatus, errorOutput: errorString)
        }
    }
}


enum ShellError: Error, LocalizedError {
    case commandFailed(terminationStatus: Int32, errorOutput: String)
    
    var errorDescription: String? {
        switch self {
        case .commandFailed(let status, let output):
            return "Command failed with exit code \(status). Output: \(output)"
        }
    }
}
