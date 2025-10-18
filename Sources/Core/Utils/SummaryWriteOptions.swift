//
//  SummaryWriteOptions.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/9/23.
//

/**
 Options for write operation in the Summary class.
 */
public struct SummaryWriteOptions {
    /**
     Indicates whether to overwrite all existing content in the summary file with the buffer contents.
     - Default: `false`
     */
    public let overwrite: Bool

    /**
     Initializes a new instance of SummaryWriteOptions.

     - Parameter overwrite: Whether to overwrite the file (default: false).
     */
    public init(overwrite: Bool = false) {
        self.overwrite = overwrite
    }
}
