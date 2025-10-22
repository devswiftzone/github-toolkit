//
//  AllGitignoreTemplateNames.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Get all gitignore templates
  /// https://docs.github.com/en/rest/gitignore/gitignore#get-all-gitignore-templates
  /// - Returns: [String]
  public func allGitignoreTemplateNames() async throws -> [String] {
    let path = "/gitignore/templates"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, _) = try await session.data(for: request)
    
    let templates = try decode([String].self, from: data)
    
    return templates
  }
}
