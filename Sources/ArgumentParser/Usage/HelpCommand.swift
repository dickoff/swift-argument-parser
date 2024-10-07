//===----------------------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Argument Parser open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

struct HelpCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "help",
    abstract: "Show subcommand help information.",
    helpNames: [])
  
  /// Any subcommand names provided after the `help` subcommand.
  @Argument var subcommands: [String] = []
  
  /// Capture and ignore any extra help flags given by the user.
  @Flag(name: [.short, .long, .customLong("help", withSingleDash: true)], help: .private)
  var help = false

  @Option(name: [.short], help: "Search for a string in the commands help output")
  var search : String?
  
  private(set) var commandStack: [ParsableCommand.Type] = []
  private(set) var visibility: ArgumentVisibility = .default

  init() {}
  
  mutating func run() throws {
    throw CommandError(
      commandStack: commandStack,
      parserError: .helpRequested(visibility: visibility, search: search))
  }
  
  mutating func buildCommandStack(with parser: CommandParser) throws {
    commandStack = parser.commandStack(for: subcommands)
  }

  /// Used for testing.
  func generateHelp(screenWidth: Int) -> String {
    HelpGenerator(
      commandStack: commandStack,
      visibility: visibility,
      search: search)
      .rendered(screenWidth: screenWidth)
  }
  
  enum CodingKeys: CodingKey {
    case subcommands
    case help
    case search
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subcommands = try container.decode([String].self, forKey: .subcommands)
    self.help = try container.decode(Bool.self, forKey: .help)
    //TODO: needed?
    self.search = try container.decode(String.self, forKey: .search)
  }
  
  init(commandStack: [ParsableCommand.Type], visibility: ArgumentVisibility) {
    self.commandStack = commandStack
    self.visibility = visibility
    self.subcommands = commandStack.map { $0._commandName }
    self.help = false
    //TODO: Needed?
    self.search = search
  }
}
