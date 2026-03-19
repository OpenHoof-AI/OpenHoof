package ai.openhoof.app.node

import ai.openhoof.app.protocol.OpenHoofCalendarCommand
import ai.openhoof.app.protocol.OpenHoofCameraCommand
import ai.openhoof.app.protocol.OpenHoofCallLogCommand
import ai.openhoof.app.protocol.OpenHoofCapability
import ai.openhoof.app.protocol.OpenHoofContactsCommand
import ai.openhoof.app.protocol.OpenHoofDeviceCommand
import ai.openhoof.app.protocol.OpenHoofLocationCommand
import ai.openhoof.app.protocol.OpenHoofMotionCommand
import ai.openhoof.app.protocol.OpenHoofNotificationsCommand
import ai.openhoof.app.protocol.OpenHoofPhotosCommand
import ai.openhoof.app.protocol.OpenHoofSmsCommand
import ai.openhoof.app.protocol.OpenHoofSystemCommand
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class InvokeCommandRegistryTest {
  private val coreCapabilities =
    setOf(
      OpenHoofCapability.Canvas.rawValue,
      OpenHoofCapability.Device.rawValue,
      OpenHoofCapability.Notifications.rawValue,
      OpenHoofCapability.System.rawValue,
      OpenHoofCapability.Photos.rawValue,
      OpenHoofCapability.Contacts.rawValue,
      OpenHoofCapability.Calendar.rawValue,
      OpenHoofCapability.CallLog.rawValue,
    )

  private val optionalCapabilities =
    setOf(
      OpenHoofCapability.Camera.rawValue,
      OpenHoofCapability.Location.rawValue,
      OpenHoofCapability.Sms.rawValue,
      OpenHoofCapability.VoiceWake.rawValue,
      OpenHoofCapability.Motion.rawValue,
    )

  private val coreCommands =
    setOf(
      OpenHoofDeviceCommand.Status.rawValue,
      OpenHoofDeviceCommand.Info.rawValue,
      OpenHoofDeviceCommand.Permissions.rawValue,
      OpenHoofDeviceCommand.Health.rawValue,
      OpenHoofNotificationsCommand.List.rawValue,
      OpenHoofNotificationsCommand.Actions.rawValue,
      OpenHoofSystemCommand.Notify.rawValue,
      OpenHoofPhotosCommand.Latest.rawValue,
      OpenHoofContactsCommand.Search.rawValue,
      OpenHoofContactsCommand.Add.rawValue,
      OpenHoofCalendarCommand.Events.rawValue,
      OpenHoofCalendarCommand.Add.rawValue,
      OpenHoofCallLogCommand.Search.rawValue,
    )

  private val optionalCommands =
    setOf(
      OpenHoofCameraCommand.Snap.rawValue,
      OpenHoofCameraCommand.Clip.rawValue,
      OpenHoofCameraCommand.List.rawValue,
      OpenHoofLocationCommand.Get.rawValue,
      OpenHoofMotionCommand.Activity.rawValue,
      OpenHoofMotionCommand.Pedometer.rawValue,
      OpenHoofSmsCommand.Send.rawValue,
    )

  private val debugCommands = setOf("debug.logs", "debug.ed25519")

  @Test
  fun advertisedCapabilities_respectsFeatureAvailability() {
    val capabilities = InvokeCommandRegistry.advertisedCapabilities(defaultFlags())

    assertContainsAll(capabilities, coreCapabilities)
    assertMissingAll(capabilities, optionalCapabilities)
  }

  @Test
  fun advertisedCapabilities_includesFeatureCapabilitiesWhenEnabled() {
    val capabilities =
      InvokeCommandRegistry.advertisedCapabilities(
        defaultFlags(
          cameraEnabled = true,
          locationEnabled = true,
          smsAvailable = true,
          voiceWakeEnabled = true,
          motionActivityAvailable = true,
          motionPedometerAvailable = true,
        ),
      )

    assertContainsAll(capabilities, coreCapabilities + optionalCapabilities)
  }

  @Test
  fun advertisedCommands_respectsFeatureAvailability() {
    val commands = InvokeCommandRegistry.advertisedCommands(defaultFlags())

    assertContainsAll(commands, coreCommands)
    assertMissingAll(commands, optionalCommands + debugCommands)
  }

  @Test
  fun advertisedCommands_includesFeatureCommandsWhenEnabled() {
    val commands =
      InvokeCommandRegistry.advertisedCommands(
        defaultFlags(
          cameraEnabled = true,
          locationEnabled = true,
          smsAvailable = true,
          motionActivityAvailable = true,
          motionPedometerAvailable = true,
          debugBuild = true,
        ),
      )

    assertContainsAll(commands, coreCommands + optionalCommands + debugCommands)
  }

  @Test
  fun advertisedCommands_onlyIncludesSupportedMotionCommands() {
    val commands =
      InvokeCommandRegistry.advertisedCommands(
        NodeRuntimeFlags(
          cameraEnabled = false,
          locationEnabled = false,
          smsAvailable = false,
          voiceWakeEnabled = false,
          motionActivityAvailable = true,
          motionPedometerAvailable = false,
          debugBuild = false,
        ),
      )

    assertTrue(commands.contains(OpenHoofMotionCommand.Activity.rawValue))
    assertFalse(commands.contains(OpenHoofMotionCommand.Pedometer.rawValue))
  }

  private fun defaultFlags(
    cameraEnabled: Boolean = false,
    locationEnabled: Boolean = false,
    smsAvailable: Boolean = false,
    voiceWakeEnabled: Boolean = false,
    motionActivityAvailable: Boolean = false,
    motionPedometerAvailable: Boolean = false,
    debugBuild: Boolean = false,
  ): NodeRuntimeFlags =
    NodeRuntimeFlags(
      cameraEnabled = cameraEnabled,
      locationEnabled = locationEnabled,
      smsAvailable = smsAvailable,
      voiceWakeEnabled = voiceWakeEnabled,
      motionActivityAvailable = motionActivityAvailable,
      motionPedometerAvailable = motionPedometerAvailable,
      debugBuild = debugBuild,
    )

  private fun assertContainsAll(actual: List<String>, expected: Set<String>) {
    expected.forEach { value -> assertTrue(actual.contains(value)) }
  }

  private fun assertMissingAll(actual: List<String>, forbidden: Set<String>) {
    forbidden.forEach { value -> assertFalse(actual.contains(value)) }
  }
}
