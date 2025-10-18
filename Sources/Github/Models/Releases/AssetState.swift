//
//  AssetState.swift
//  
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation

extension Asset {
  public enum State: String, Codable, Sendable {
    case uploaded
    case open
  }
}
