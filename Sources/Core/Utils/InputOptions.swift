//
//  InputOptions.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/9/23.
//

/**
 * Struct for getInput options
 */
public struct InputOptions {
    /** Optional. Whether the input is required. If required and not present, will throw. Defaults to false */
    public let required: Bool?
    
    /** Optional. Whether leading/trailing whitespace will be trimmed for the input. Defaults to true */
    public let trimWhitespace: Bool?
    
    public init(required: Bool?, trimWhitespace: Bool?) {
        self.required = required
        self.trimWhitespace = trimWhitespace
    }
}
