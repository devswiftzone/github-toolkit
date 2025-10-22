//
//  GetGitignoreTemplate.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Get a gitignore template
  /// https://docs.github.com/en/rest/gitignore/gitignore#get-a-gitignore-template
  /// - Returns: GitignoreTemplate
  public func gitignoreTemplate(
    name: String
  ) async throws -> GitignoreTemplate {
    let path = "/gitignore/templates/\(name)"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, _) = try await execute( request)
    
    let template = try decode(GitignoreTemplate.self, from: data)
    
    return template
  }
}
