//
// Copyright © 2026 Alexander Romanov
// AppUpdate.swift, created on 04.03.2026
//

import OversizeArchitecture
import OversizeNetwork

@Module
public enum AppUpdate: ModuleProtocol {}

public struct AppUpdateInput: Sendable {
    public enum Source: Sendable {
        case version(Components.Schemas.Version)
        case versionString(String)
    }

    public let source: Source

    public init(version: Components.Schemas.Version) {
        source = .version(version)
    }

    public init(versionString: String) {
        source = .versionString(versionString)
    }
}

public struct AppUpdateOutput: Sendable {}
