package ai.openhoof.app.node

import ai.openhoof.app.protocol.OpenHoofCalendarCommand
import ai.openhoof.app.protocol.OpenHoofCanvasA2UICommand
import ai.openhoof.app.protocol.OpenHoofCanvasCommand
import ai.openhoof.app.protocol.OpenHoofCameraCommand
import ai.openhoof.app.protocol.OpenHoofCapability
import ai.openhoof.app.protocol.OpenHoofCallLogCommand
import ai.openhoof.app.protocol.OpenHoofContactsCommand
import ai.openhoof.app.protocol.OpenHoofDeviceCommand
import ai.openhoof.app.protocol.OpenHoofLocationCommand
import ai.openhoof.app.protocol.OpenHoofMotionCommand
import ai.openhoof.app.protocol.OpenHoofNotificationsCommand
import ai.openhoof.app.protocol.OpenHoofPhotosCommand
import ai.openhoof.app.protocol.OpenHoofSmsCommand
import ai.openhoof.app.protocol.OpenHoofSystemCommand

data class NodeRuntimeFlags(
  val cameraEnabled: Boolean,
  val locationEnabled: Boolean,
  val smsAvailable: Boolean,
  val voiceWakeEnabled: Boolean,
  val motionActivityAvailable: Boolean,
  val motionPedometerAvailable: Boolean,
  val debugBuild: Boolean,
)

enum class InvokeCommandAvailability {
  Always,
  CameraEnabled,
  LocationEnabled,
  SmsAvailable,
  MotionActivityAvailable,
  MotionPedometerAvailable,
  DebugBuild,
}

enum class NodeCapabilityAvailability {
  Always,
  CameraEnabled,
  LocationEnabled,
  SmsAvailable,
  VoiceWakeEnabled,
  MotionAvailable,
}

data class NodeCapabilitySpec(
  val name: String,
  val availability: NodeCapabilityAvailability = NodeCapabilityAvailability.Always,
)

data class InvokeCommandSpec(
  val name: String,
  val requiresForeground: Boolean = false,
  val availability: InvokeCommandAvailability = InvokeCommandAvailability.Always,
)

object InvokeCommandRegistry {
  val capabilityManifest: List<NodeCapabilitySpec> =
    listOf(
      NodeCapabilitySpec(name = OpenHoofCapability.Canvas.rawValue),
      NodeCapabilitySpec(name = OpenHoofCapability.Device.rawValue),
      NodeCapabilitySpec(name = OpenHoofCapability.Notifications.rawValue),
      NodeCapabilitySpec(name = OpenHoofCapability.System.rawValue),
      NodeCapabilitySpec(
        name = OpenHoofCapability.Camera.rawValue,
        availability = NodeCapabilityAvailability.CameraEnabled,
      ),
      NodeCapabilitySpec(
        name = OpenHoofCapability.Sms.rawValue,
        availability = NodeCapabilityAvailability.SmsAvailable,
      ),
      NodeCapabilitySpec(
        name = OpenHoofCapability.VoiceWake.rawValue,
        availability = NodeCapabilityAvailability.VoiceWakeEnabled,
      ),
      NodeCapabilitySpec(
        name = OpenHoofCapability.Location.rawValue,
        availability = NodeCapabilityAvailability.LocationEnabled,
      ),
      NodeCapabilitySpec(name = OpenHoofCapability.Photos.rawValue),
      NodeCapabilitySpec(name = OpenHoofCapability.Contacts.rawValue),
      NodeCapabilitySpec(name = OpenHoofCapability.Calendar.rawValue),
      NodeCapabilitySpec(
        name = OpenHoofCapability.Motion.rawValue,
        availability = NodeCapabilityAvailability.MotionAvailable,
      ),
      NodeCapabilitySpec(name = OpenHoofCapability.CallLog.rawValue),
    )

  val all: List<InvokeCommandSpec> =
    listOf(
      InvokeCommandSpec(
        name = OpenHoofCanvasCommand.Present.rawValue,
        requiresForeground = true,
      ),
      InvokeCommandSpec(
        name = OpenHoofCanvasCommand.Hide.rawValue,
        requiresForeground = true,
      ),
      InvokeCommandSpec(
        name = OpenHoofCanvasCommand.Navigate.rawValue,
        requiresForeground = true,
      ),
      InvokeCommandSpec(
        name = OpenHoofCanvasCommand.Eval.rawValue,
        requiresForeground = true,
      ),
      InvokeCommandSpec(
        name = OpenHoofCanvasCommand.Snapshot.rawValue,
        requiresForeground = true,
      ),
      InvokeCommandSpec(
        name = OpenHoofCanvasA2UICommand.Push.rawValue,
        requiresForeground = true,
      ),
      InvokeCommandSpec(
        name = OpenHoofCanvasA2UICommand.PushJSONL.rawValue,
        requiresForeground = true,
      ),
      InvokeCommandSpec(
        name = OpenHoofCanvasA2UICommand.Reset.rawValue,
        requiresForeground = true,
      ),
      InvokeCommandSpec(
        name = OpenHoofSystemCommand.Notify.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofCameraCommand.List.rawValue,
        requiresForeground = true,
        availability = InvokeCommandAvailability.CameraEnabled,
      ),
      InvokeCommandSpec(
        name = OpenHoofCameraCommand.Snap.rawValue,
        requiresForeground = true,
        availability = InvokeCommandAvailability.CameraEnabled,
      ),
      InvokeCommandSpec(
        name = OpenHoofCameraCommand.Clip.rawValue,
        requiresForeground = true,
        availability = InvokeCommandAvailability.CameraEnabled,
      ),
      InvokeCommandSpec(
        name = OpenHoofLocationCommand.Get.rawValue,
        availability = InvokeCommandAvailability.LocationEnabled,
      ),
      InvokeCommandSpec(
        name = OpenHoofDeviceCommand.Status.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofDeviceCommand.Info.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofDeviceCommand.Permissions.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofDeviceCommand.Health.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofNotificationsCommand.List.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofNotificationsCommand.Actions.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofPhotosCommand.Latest.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofContactsCommand.Search.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofContactsCommand.Add.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofCalendarCommand.Events.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofCalendarCommand.Add.rawValue,
      ),
      InvokeCommandSpec(
        name = OpenHoofMotionCommand.Activity.rawValue,
        availability = InvokeCommandAvailability.MotionActivityAvailable,
      ),
      InvokeCommandSpec(
        name = OpenHoofMotionCommand.Pedometer.rawValue,
        availability = InvokeCommandAvailability.MotionPedometerAvailable,
      ),
      InvokeCommandSpec(
        name = OpenHoofSmsCommand.Send.rawValue,
        availability = InvokeCommandAvailability.SmsAvailable,
      ),
      InvokeCommandSpec(
        name = OpenHoofCallLogCommand.Search.rawValue,
      ),
      InvokeCommandSpec(
        name = "debug.logs",
        availability = InvokeCommandAvailability.DebugBuild,
      ),
      InvokeCommandSpec(
        name = "debug.ed25519",
        availability = InvokeCommandAvailability.DebugBuild,
      ),
    )

  private val byNameInternal: Map<String, InvokeCommandSpec> = all.associateBy { it.name }

  fun find(command: String): InvokeCommandSpec? = byNameInternal[command]

  fun advertisedCapabilities(flags: NodeRuntimeFlags): List<String> {
    return capabilityManifest
      .filter { spec ->
        when (spec.availability) {
          NodeCapabilityAvailability.Always -> true
          NodeCapabilityAvailability.CameraEnabled -> flags.cameraEnabled
          NodeCapabilityAvailability.LocationEnabled -> flags.locationEnabled
          NodeCapabilityAvailability.SmsAvailable -> flags.smsAvailable
          NodeCapabilityAvailability.VoiceWakeEnabled -> flags.voiceWakeEnabled
          NodeCapabilityAvailability.MotionAvailable -> flags.motionActivityAvailable || flags.motionPedometerAvailable
        }
      }
      .map { it.name }
  }

  fun advertisedCommands(flags: NodeRuntimeFlags): List<String> {
    return all
      .filter { spec ->
        when (spec.availability) {
          InvokeCommandAvailability.Always -> true
          InvokeCommandAvailability.CameraEnabled -> flags.cameraEnabled
          InvokeCommandAvailability.LocationEnabled -> flags.locationEnabled
          InvokeCommandAvailability.SmsAvailable -> flags.smsAvailable
          InvokeCommandAvailability.MotionActivityAvailable -> flags.motionActivityAvailable
          InvokeCommandAvailability.MotionPedometerAvailable -> flags.motionPedometerAvailable
          InvokeCommandAvailability.DebugBuild -> flags.debugBuild
        }
      }
      .map { it.name }
  }
}
