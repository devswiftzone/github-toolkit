//
//  CreateRepositoryWithTemplate.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation
import HttpClient
import HTTPTypes

@available(macOS 13.0, *)
extension GitHub {
  /// Create a repository using a template
  /// https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#create-a-repository-using-a-template
  /// - Parameters:
  ///   - templateOwnerID: The account owner of the template repository. The name is not case sensitive.
  ///   - templateRepositoryName: The name of the template repository without the .git extension. The name is not case sensitive.
  ///   - name: The name of the new repository.
  ///   - description: A short description of the new repository.
  ///   - includeAllBranches: Set to true to include the directory structure and files from all branches in the template repository, and not just the default branch.
  ///   - isPrivate: Either true to create a new private repository or false to create a new public one.
  /// - Returns: Repository
  public func createRepository(
    templateOwnerID: String,
    templateRepositoryName: String,
    name: String,
    description: String? = nil,
    includeAllBranches: Bool = false,
    isPrivate: Bool = false
  ) async throws -> Repository {
    let path = "/repos/\(templateOwnerID)/\(templateRepositoryName)/generate"
    let method: HTTPRequest.Method = .post
    let endpoint = baseURL.appending(path: path)
    
    let newRepository = NewRepositoryWithTemplate(
      name: name,
      description: description,
      includeAllBranches: includeAllBranches,
      isPrivate: isPrivate
    )
  
    let body = try JSONEncoder.github.encode(newRepository)
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers )
    
    let bodyData = body
    
    let (data, _) = try await execute(request, body: bodyData)
    
    let repository = try decode(Repository.self, from: data)
    
    return repository
  }
}

struct NewRepositoryWithTemplate: Encodable {
  let name: String
  let description: String?
  let includeAllBranches: Bool
  let isPrivate: Bool
  
  private enum CodingKeys: String, CodingKey {
    case name
    case description
    case includeAllBranches = "include_all_branches"
    case isPrivate = "private"
  }
}
