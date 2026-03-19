package ai.openhoof.app.protocol

import org.junit.Assert.assertEquals
import org.junit.Test

class OpenHoofProtocolConstantsTest {
  @Test
  fun canvasCommandsUseStableStrings() {
    assertEquals("canvas.present", OpenHoofCanvasCommand.Present.rawValue)
    assertEquals("canvas.hide", OpenHoofCanvasCommand.Hide.rawValue)
    assertEquals("canvas.navigate", OpenHoofCanvasCommand.Navigate.rawValue)
    assertEquals("canvas.eval", OpenHoofCanvasCommand.Eval.rawValue)
    assertEquals("canvas.snapshot", OpenHoofCanvasCommand.Snapshot.rawValue)
  }

  @Test
  fun a2uiCommandsUseStableStrings() {
    assertEquals("canvas.a2ui.push", OpenHoofCanvasA2UICommand.Push.rawValue)
    assertEquals("canvas.a2ui.pushJSONL", OpenHoofCanvasA2UICommand.PushJSONL.rawValue)
    assertEquals("canvas.a2ui.reset", OpenHoofCanvasA2UICommand.Reset.rawValue)
  }

  @Test
  fun capabilitiesUseStableStrings() {
    assertEquals("canvas", OpenHoofCapability.Canvas.rawValue)
    assertEquals("camera", OpenHoofCapability.Camera.rawValue)
    assertEquals("voiceWake", OpenHoofCapability.VoiceWake.rawValue)
    assertEquals("location", OpenHoofCapability.Location.rawValue)
    assertEquals("sms", OpenHoofCapability.Sms.rawValue)
    assertEquals("device", OpenHoofCapability.Device.rawValue)
    assertEquals("notifications", OpenHoofCapability.Notifications.rawValue)
    assertEquals("system", OpenHoofCapability.System.rawValue)
    assertEquals("photos", OpenHoofCapability.Photos.rawValue)
    assertEquals("contacts", OpenHoofCapability.Contacts.rawValue)
    assertEquals("calendar", OpenHoofCapability.Calendar.rawValue)
    assertEquals("motion", OpenHoofCapability.Motion.rawValue)
    assertEquals("callLog", OpenHoofCapability.CallLog.rawValue)
  }

  @Test
  fun cameraCommandsUseStableStrings() {
    assertEquals("camera.list", OpenHoofCameraCommand.List.rawValue)
    assertEquals("camera.snap", OpenHoofCameraCommand.Snap.rawValue)
    assertEquals("camera.clip", OpenHoofCameraCommand.Clip.rawValue)
  }

  @Test
  fun notificationsCommandsUseStableStrings() {
    assertEquals("notifications.list", OpenHoofNotificationsCommand.List.rawValue)
    assertEquals("notifications.actions", OpenHoofNotificationsCommand.Actions.rawValue)
  }

  @Test
  fun deviceCommandsUseStableStrings() {
    assertEquals("device.status", OpenHoofDeviceCommand.Status.rawValue)
    assertEquals("device.info", OpenHoofDeviceCommand.Info.rawValue)
    assertEquals("device.permissions", OpenHoofDeviceCommand.Permissions.rawValue)
    assertEquals("device.health", OpenHoofDeviceCommand.Health.rawValue)
  }

  @Test
  fun systemCommandsUseStableStrings() {
    assertEquals("system.notify", OpenHoofSystemCommand.Notify.rawValue)
  }

  @Test
  fun photosCommandsUseStableStrings() {
    assertEquals("photos.latest", OpenHoofPhotosCommand.Latest.rawValue)
  }

  @Test
  fun contactsCommandsUseStableStrings() {
    assertEquals("contacts.search", OpenHoofContactsCommand.Search.rawValue)
    assertEquals("contacts.add", OpenHoofContactsCommand.Add.rawValue)
  }

  @Test
  fun calendarCommandsUseStableStrings() {
    assertEquals("calendar.events", OpenHoofCalendarCommand.Events.rawValue)
    assertEquals("calendar.add", OpenHoofCalendarCommand.Add.rawValue)
  }

  @Test
  fun motionCommandsUseStableStrings() {
    assertEquals("motion.activity", OpenHoofMotionCommand.Activity.rawValue)
    assertEquals("motion.pedometer", OpenHoofMotionCommand.Pedometer.rawValue)
  }

  @Test
  fun callLogCommandsUseStableStrings() {
    assertEquals("callLog.search", OpenHoofCallLogCommand.Search.rawValue)
  }
}
