//
//  ReleaseRequest.swift
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
  /// Get a release
  /// https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#get-a-release
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - releaseID: The unique identifier of the release.
  /// - Returns: Release
  public func release(
    ownerID: String,
    repositoryName: String,
    releaseID: Int
  ) async throws -> Release {
    let path = "/repos/\(ownerID)/\(repositoryName)/releases/\(releaseID)"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, _) = try await session.data(for: request)
    
    let release = try decode(Release.self, from: data)
    
    return release
  }
  
  /// Get a release by tag name
  /// https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#get-a-release-by-tag-name
  /// - Parameters:
  ///   - ownerID: The account owner of the repository. The name is not case sensitive.
  ///   - repositoryName: The name of the repository without the .git extension. The name is not case sensitive.
  ///   - tag: tag parameter
  /// - Returns: Release
  public func release(
    ownerID: String,
    repositoryName: String,
    tag: String
  ) async throws -> Release {
    let path = "/repos/\(ownerID)/\(repositoryName)/releases/tags/\(tag)"
    let endpoint = baseURL.appending(path: path)
    let method: HTTPRequest.Method = .get
    
    let request = HTTPRequest(method: method, url: endpoint, queries: [:], headers: headers)
    
    let (data, _) = try await session.data(for: request)
    
    let release = try decode(Release.self, from: data)
    
    return release
  }
}
