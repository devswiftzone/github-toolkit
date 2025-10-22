//
//  Summary.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/9/23.
//

import Foundation

/**
 * Errors that can occur when working with summaries.
 */
public enum SummaryError: Error, LocalizedError {
    case environmentVariableNotFound(String)
    case fileNotReadable(String)
    case fileNotWritable(String)

    public var errorDescription: String? {
        switch self {
        case .environmentVariableNotFound(let message),
             .fileNotReadable(let message),
             .fileNotWritable(let message):
            return message
        }
    }
}

/**
 * The summary class is used to construct a summary file for a GitHub Action workflow step.
 * The summary can include various types of content, such as text, code blocks, lists, tables, and more.
 */
public class Summary {
    private var buffer: String
    private var filePath: String?
    
    /**
     * Initializes a new instance of the Summary class.
     */
    public init() {
        self.buffer = ""
    }
    
    /**
     * Finds the summary file path from the environment, rejects if env var is not found or file does not exist.
     * Also checks read/write permissions.
     *
     * - Returns: Step summary file path.
     */
    private func getfilePath() throws -> String {
        guard let filePath = ProcessInfo.processInfo.environment["GITHUB_STEP_SUMMARY"] else {
            throw SummaryError.environmentVariableNotFound("GITHUB_STEP_SUMMARY environment variable is not set")
        }

        // Check if file exists, if not try to create it
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: filePath) {
            // Try to create the file
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }

        // Check if file is readable and writable
        guard fileManager.isReadableFile(atPath: filePath) else {
            throw SummaryError.fileNotReadable("Summary file at \(filePath) is not readable")
        }

        guard fileManager.isWritableFile(atPath: filePath) else {
            throw SummaryError.fileNotWritable("Summary file at \(filePath) is not writable")
        }

        return filePath
    }
    
    /**
     * Writes text in the buffer to the summary buffer file and empties the buffer. Will append by default.
     *
     * - Parameter options: Options for write operation (optional, default: nil).
     *
     * - Returns: Summary instance.
     */
    public func write(options: SummaryWriteOptions? = nil) throws -> Summary {
        let overwrite = options?.overwrite ?? false
        let filePath = try getfilePath()
        let url = URL(fileURLWithPath: filePath)

        if overwrite {
            // Overwrite the file with buffer content
            try buffer.write(to: url, atomically: true, encoding: .utf8)
        } else {
            // Append buffer content to existing file
            let fileManager = FileManager.default

            if fileManager.fileExists(atPath: filePath) {
                // Read existing content
                let existingContent = try String(contentsOf: url, encoding: .utf8)
                let newContent = existingContent + buffer
                try newContent.write(to: url, atomically: true, encoding: .utf8)
            } else {
                // File doesn't exist, create it with buffer content
                try buffer.write(to: url, atomically: true, encoding: .utf8)
            }
        }

        // Clear buffer after writing
        buffer = ""

        return self
    }
    
    /**
     * Clears the summary buffer and wipes the summary file.
     *
     * - Returns: Summary instance.
     */
    public func clear() throws -> Summary {
        // Clear the buffer
        buffer = ""

        // Wipe the summary file by writing empty content
        let filePath = try getfilePath()
        let url = URL(fileURLWithPath: filePath)
        try "".write(to: url, atomically: true, encoding: .utf8)

        return self
    }

    /**
     * Adds raw text to the summary buffer.
     *
     * - Parameter text: The text to add.
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addRaw(_ text: String, addEOL: Bool = false) -> Summary {
        buffer += text
        if addEOL {
            buffer += "\n"
        }
        return self
    }

    /**
     * Adds an HTML tag with optional content to the summary buffer.
     *
     * - Parameters:
     *   - tag: The HTML tag name.
     *   - text: The text content inside the tag.
     *   - close: Whether to close the tag (default: true).
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addTag(_ tag: String, text: String? = nil, close: Bool = true) -> Summary {
        buffer += "<\(tag)>"
        if let text = text {
            buffer += text
        }
        if close {
            buffer += "</\(tag)>\n"
        }
        return self
    }

    /**
     * Adds a heading to the summary.
     *
     * - Parameters:
     *   - text: The heading text.
     *   - level: The heading level (1-6, default: 1).
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addHeading(_ text: String, level: Int = 1) -> Summary {
        let clampedLevel = max(1, min(6, level))
        buffer += String(repeating: "#", count: clampedLevel) + " \(text)\n"
        return self
    }

    /**
     * Adds a code block to the summary.
     *
     * - Parameters:
     *   - code: The code content.
     *   - language: The programming language for syntax highlighting (optional).
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addCodeBlock(_ code: String, language: String? = nil) -> Summary {
        let lang = language ?? ""
        buffer += "```\(lang)\n\(code)\n```\n"
        return self
    }

    /**
     * Adds a list to the summary.
     *
     * - Parameters:
     *   - items: The list items.
     *   - ordered: Whether the list is ordered (default: false).
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addList(_ items: [String], ordered: Bool = false) -> Summary {
        for (index, item) in items.enumerated() {
            if ordered {
                buffer += "\(index + 1). \(item)\n"
            } else {
                buffer += "- \(item)\n"
            }
        }
        return self
    }

    /**
     * Adds a table to the summary.
     *
     * - Parameter rows: The table rows, where each row is an array of cell values.
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addTable(_ rows: [[String]]) -> Summary {
        guard !rows.isEmpty else { return self }

        // Add header row
        buffer += "| " + rows[0].joined(separator: " | ") + " |\n"

        // Add separator
        buffer += "|" + String(repeating: " --- |", count: rows[0].count) + "\n"

        // Add data rows
        for row in rows.dropFirst() {
            buffer += "| " + row.joined(separator: " | ") + " |\n"
        }

        return self
    }

    /**
     * Adds a horizontal rule to the summary.
     *
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addSeparator() -> Summary {
        buffer += "---\n"
        return self
    }

    /**
     * Adds a line break to the summary.
     *
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addBreak() -> Summary {
        buffer += "\n"
        return self
    }

    /**
     * Adds a quote to the summary.
     *
     * - Parameter text: The quoted text.
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addQuote(_ text: String) -> Summary {
        buffer += "> \(text)\n"
        return self
    }

    /**
     * Adds a link to the summary.
     *
     * - Parameters:
     *   - text: The link text.
     *   - url: The URL.
     * - Returns: Summary instance.
     */
    @discardableResult
    public func addLink(_ text: String, url: String) -> Summary {
        buffer += "[\(text)](\(url))\n"
        return self
    }

    /**
     * Checks if the buffer is empty.
     *
     * - Returns: True if buffer is empty, false otherwise.
     */
    public func isEmpty() -> Bool {
        return buffer.isEmpty
    }
}

public extension Core {
    static var summary: Summary { Summary() }
}
