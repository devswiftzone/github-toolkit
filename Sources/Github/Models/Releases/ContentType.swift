//
//  ContentType.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 9/14/23.
//

import Foundation

extension Asset {
  public enum ContentType: String, Codable, Sendable {
    case zip = "application/zip"
    case octet_stream = "application/octet-stream"
    case x_tar = "application/x-tar"
    case pgp_signature = "application/pgp-signature"
    case x_debian_package = "application/x-debian-package"
    case x_gzip = "application/x-gzip"
    case x_msdownload = "application/x-msdownload"
  }
}
