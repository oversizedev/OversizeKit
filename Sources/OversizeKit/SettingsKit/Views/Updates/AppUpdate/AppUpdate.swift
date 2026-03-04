//
// Copyright © 2026 Alexander Romanov
// AppUpdate.swift, created on 04.03.2026
//

import OversizeArchitecture
import OversizeNetwork

@Module
public enum AppUpdate: ModuleProtocol {}

public typealias AppUpdateInput = Components.Schemas.Version

public struct AppUpdateOutput: Sendable {}
