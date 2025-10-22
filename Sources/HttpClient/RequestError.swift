//
//  RequestError.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation

public enum RequestError: Error, Sendable {
  case deleteRepository(data: Data)
  case deleteProtectionTag(data: Data)
  case notFound
  case notAuthorized
  case requireAuthorization
  case httpError(statusCode: Int, data: Data)
}
