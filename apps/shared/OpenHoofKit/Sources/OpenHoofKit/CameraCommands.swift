import Foundation

public enum OpenHoofCameraCommand: String, Codable, Sendable {
    case list = "camera.list"
    case snap = "camera.snap"
    case clip = "camera.clip"
}

public enum OpenHoofCameraFacing: String, Codable, Sendable {
    case back
    case front
}

public enum OpenHoofCameraImageFormat: String, Codable, Sendable {
    case jpg
    case jpeg
}

public enum OpenHoofCameraVideoFormat: String, Codable, Sendable {
    case mp4
}

public struct OpenHoofCameraSnapParams: Codable, Sendable, Equatable {
    public var facing: OpenHoofCameraFacing?
    public var maxWidth: Int?
    public var quality: Double?
    public var format: OpenHoofCameraImageFormat?
    public var deviceId: String?
    public var delayMs: Int?

    public init(
        facing: OpenHoofCameraFacing? = nil,
        maxWidth: Int? = nil,
        quality: Double? = nil,
        format: OpenHoofCameraImageFormat? = nil,
        deviceId: String? = nil,
        delayMs: Int? = nil)
    {
        self.facing = facing
        self.maxWidth = maxWidth
        self.quality = quality
        self.format = format
        self.deviceId = deviceId
        self.delayMs = delayMs
    }
}

public struct OpenHoofCameraClipParams: Codable, Sendable, Equatable {
    public var facing: OpenHoofCameraFacing?
    public var durationMs: Int?
    public var includeAudio: Bool?
    public var format: OpenHoofCameraVideoFormat?
    public var deviceId: String?

    public init(
        facing: OpenHoofCameraFacing? = nil,
        durationMs: Int? = nil,
        includeAudio: Bool? = nil,
        format: OpenHoofCameraVideoFormat? = nil,
        deviceId: String? = nil)
    {
        self.facing = facing
        self.durationMs = durationMs
        self.includeAudio = includeAudio
        self.format = format
        self.deviceId = deviceId
    }
}
