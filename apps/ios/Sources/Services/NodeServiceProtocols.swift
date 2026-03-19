import CoreLocation
import Foundation
import OpenHoofKit
import UIKit

typealias OpenHoofCameraSnapResult = (format: String, base64: String, width: Int, height: Int)
typealias OpenHoofCameraClipResult = (format: String, base64: String, durationMs: Int, hasAudio: Bool)

protocol CameraServicing: Sendable {
    func listDevices() async -> [CameraController.CameraDeviceInfo]
    func snap(params: OpenHoofCameraSnapParams) async throws -> OpenHoofCameraSnapResult
    func clip(params: OpenHoofCameraClipParams) async throws -> OpenHoofCameraClipResult
}

protocol ScreenRecordingServicing: Sendable {
    func record(
        screenIndex: Int?,
        durationMs: Int?,
        fps: Double?,
        includeAudio: Bool?,
        outPath: String?) async throws -> String
}

@MainActor
protocol LocationServicing: Sendable {
    func authorizationStatus() -> CLAuthorizationStatus
    func accuracyAuthorization() -> CLAccuracyAuthorization
    func ensureAuthorization(mode: OpenHoofLocationMode) async -> CLAuthorizationStatus
    func currentLocation(
        params: OpenHoofLocationGetParams,
        desiredAccuracy: OpenHoofLocationAccuracy,
        maxAgeMs: Int?,
        timeoutMs: Int?) async throws -> CLLocation
    func startLocationUpdates(
        desiredAccuracy: OpenHoofLocationAccuracy,
        significantChangesOnly: Bool) -> AsyncStream<CLLocation>
    func stopLocationUpdates()
    func startMonitoringSignificantLocationChanges(onUpdate: @escaping @Sendable (CLLocation) -> Void)
    func stopMonitoringSignificantLocationChanges()
}

@MainActor
protocol DeviceStatusServicing: Sendable {
    func status() async throws -> OpenHoofDeviceStatusPayload
    func info() -> OpenHoofDeviceInfoPayload
}

protocol PhotosServicing: Sendable {
    func latest(params: OpenHoofPhotosLatestParams) async throws -> OpenHoofPhotosLatestPayload
}

protocol ContactsServicing: Sendable {
    func search(params: OpenHoofContactsSearchParams) async throws -> OpenHoofContactsSearchPayload
    func add(params: OpenHoofContactsAddParams) async throws -> OpenHoofContactsAddPayload
}

protocol CalendarServicing: Sendable {
    func events(params: OpenHoofCalendarEventsParams) async throws -> OpenHoofCalendarEventsPayload
    func add(params: OpenHoofCalendarAddParams) async throws -> OpenHoofCalendarAddPayload
}

protocol RemindersServicing: Sendable {
    func list(params: OpenHoofRemindersListParams) async throws -> OpenHoofRemindersListPayload
    func add(params: OpenHoofRemindersAddParams) async throws -> OpenHoofRemindersAddPayload
}

protocol MotionServicing: Sendable {
    func activities(params: OpenHoofMotionActivityParams) async throws -> OpenHoofMotionActivityPayload
    func pedometer(params: OpenHoofPedometerParams) async throws -> OpenHoofPedometerPayload
}

struct WatchMessagingStatus: Sendable, Equatable {
    var supported: Bool
    var paired: Bool
    var appInstalled: Bool
    var reachable: Bool
    var activationState: String
}

struct WatchQuickReplyEvent: Sendable, Equatable {
    var replyId: String
    var promptId: String
    var actionId: String
    var actionLabel: String?
    var sessionKey: String?
    var note: String?
    var sentAtMs: Int?
    var transport: String
}

struct WatchNotificationSendResult: Sendable, Equatable {
    var deliveredImmediately: Bool
    var queuedForDelivery: Bool
    var transport: String
}

protocol WatchMessagingServicing: AnyObject, Sendable {
    func status() async -> WatchMessagingStatus
    func setReplyHandler(_ handler: (@Sendable (WatchQuickReplyEvent) -> Void)?)
    func sendNotification(
        id: String,
        params: OpenHoofWatchNotifyParams) async throws -> WatchNotificationSendResult
}

extension CameraController: CameraServicing {}
extension ScreenRecordService: ScreenRecordingServicing {}
extension LocationService: LocationServicing {}
