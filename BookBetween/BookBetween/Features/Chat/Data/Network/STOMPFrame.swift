//
//  STOMPFrame.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation

enum STOMPCommand: String {
  case connect = "CONNECT"
  case connected = "CONNECTED"
  case subscribe = "SUBSCRIBE"
  case send = "SEND"
  case message = "MESSAGE"
  case disconnect = "DISCONNECT"
  case error = "ERROR"
}

struct STOMPFrame {

  // MARK: - Properties

  let command: String
  let headers: [String: String]
  let body: String

  // MARK: - Init

  init(command: String, headers: [String: String] = [:], body: String = "") {
    self.command = command
    self.headers = headers
    self.body = body
  }

  // MARK: - Encode

  func encode() -> String {
    var lines = [self.command]
    for (key, value) in self.headers {
      lines.append("\(key):\(value)")
    }
    lines.append("")
    lines.append(self.body)
    return lines.joined(separator: "\n") + "\u{00}"
  }

  // MARK: - Parse

  static func parse(_ text: String) -> STOMPFrame? {
    let trimmed = text.hasSuffix("\u{00}") ? String(text.dropLast()) : text
    let lines = trimmed.components(separatedBy: "\n")

    guard let command = lines.first, !command.isEmpty else {
      return nil
    }

    var headers: [String: String] = [:]
    var bodyStartIndex = lines.count

    for index in 1..<lines.count {
      let line = lines[index]
      if line.isEmpty {
        bodyStartIndex = index + 1
        break
      }
      guard let separatorIndex = line.firstIndex(of: ":") else { continue }
      let key = String(line[line.startIndex..<separatorIndex])
      let value = String(line[line.index(after: separatorIndex)...])
      headers[key] = value
    }

    let body = bodyStartIndex < lines.count
      ? lines[bodyStartIndex...].joined(separator: "\n")
      : ""

    return STOMPFrame(command: command, headers: headers, body: body)
  }
}
