import Foundation

public enum OpenHoofDeviceCommand: String, Codable, Sendable {
    case status = "device.status"
    case info = "device.info"
}

public enum OpenHoofBatteryState: String, Codable, Sendable {
    case unknown
    case unplugged
    case charging
    case full
}

public enum OpenHoofThermalState: String, Codable, Sendable {
    case nominal
    case fair
    case serious
    case critical
}

public enum OpenHoofNetworkPathStatus: String, Codable, Sendable {
    case satisfied
    case unsatisfied
    case requiresConnection
}

public enum OpenHoofNetworkInterfaceType: String, Codable, Sendable {
    case wifi
    case cellular
    case wired
    case other
}

public struct OpenHoofBatteryStatusPayload: Codable, Sendable, Equatable {
    public var level: Double?
    public var state: OpenHoofBatteryState
    public var lowPowerModeEnabled: Bool

    public init(level: Double?, state: OpenHoofBatteryState, lowPowerModeEnabled: Bool) {
        self.level = level
        self.state = state
        self.lowPowerModeEnabled = lowPowerModeEnabled
    }
}

public struct OpenHoofThermalStatusPayload: Codable, Sendable, Equatable {
    public var state: OpenHoofThermalState

    public init(state: OpenHoofThermalState) {
        self.state = state
    }
}

public struct OpenHoofStorageStatusPayload: Codable, Sendable, Equatable {
    public var totalBytes: Int64
    public var freeBytes: Int64
    public var usedBytes: Int64

    public init(totalBytes: Int64, freeBytes: Int64, usedBytes: Int64) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
    }
}

public struct OpenHoofNetworkStatusPayload: Codable, Sendable, Equatable {
    public var status: OpenHoofNetworkPathStatus
    public var isExpensive: Bool
    public var isConstrained: Bool
    public var interfaces: [OpenHoofNetworkInterfaceType]

    public init(
        status: OpenHoofNetworkPathStatus,
        isExpensive: Bool,
        isConstrained: Bool,
        interfaces: [OpenHoofNetworkInterfaceType])
    {
        self.status = status
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.interfaces = interfaces
    }
}

public struct OpenHoofDeviceStatusPayload: Codable, Sendable, Equatable {
    public var battery: OpenHoofBatteryStatusPayload
    public var thermal: OpenHoofThermalStatusPayload
    public var storage: OpenHoofStorageStatusPayload
    public var network: OpenHoofNetworkStatusPayload
    public var uptimeSeconds: Double

    public init(
        battery: OpenHoofBatteryStatusPayload,
        thermal: OpenHoofThermalStatusPayload,
        storage: OpenHoofStorageStatusPayload,
        network: OpenHoofNetworkStatusPayload,
        uptimeSeconds: Double)
    {
        self.battery = battery
        self.thermal = thermal
        self.storage = storage
        self.network = network
        self.uptimeSeconds = uptimeSeconds
    }
}

public struct OpenHoofDeviceInfoPayload: Codable, Sendable, Equatable {
    public var deviceName: String
    public var modelIdentifier: String
    public var systemName: String
    public var systemVersion: String
    public var appVersion: String
    public var appBuild: String
    public var locale: String

    public init(
        deviceName: String,
        modelIdentifier: String,
        systemName: String,
        systemVersion: String,
        appVersion: String,
        appBuild: String,
        locale: String)
    {
        self.deviceName = deviceName
        self.modelIdentifier = modelIdentifier
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.locale = locale
    }
}
