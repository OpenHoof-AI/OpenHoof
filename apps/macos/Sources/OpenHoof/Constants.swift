import Foundation

// Stable identifier used for both the macOS LaunchAgent label and Nix-managed defaults suite.
// nix-openhoof writes app defaults into this suite to survive app bundle identifier churn.
let launchdLabel = "ai.openhoof.mac"
let gatewayLaunchdLabel = "ai.openhoof.gateway"
let onboardingVersionKey = "openhoof.onboardingVersion"
let onboardingSeenKey = "openhoof.onboardingSeen"
let currentOnboardingVersion = 7
let pauseDefaultsKey = "openhoof.pauseEnabled"
let iconAnimationsEnabledKey = "openhoof.iconAnimationsEnabled"
let swabbleEnabledKey = "openhoof.swabbleEnabled"
let swabbleTriggersKey = "openhoof.swabbleTriggers"
let voiceWakeTriggerChimeKey = "openhoof.voiceWakeTriggerChime"
let voiceWakeSendChimeKey = "openhoof.voiceWakeSendChime"
let showDockIconKey = "openhoof.showDockIcon"
let defaultVoiceWakeTriggers = ["openhoof"]
let voiceWakeMaxWords = 32
let voiceWakeMaxWordLength = 64
let voiceWakeMicKey = "openhoof.voiceWakeMicID"
let voiceWakeMicNameKey = "openhoof.voiceWakeMicName"
let voiceWakeLocaleKey = "openhoof.voiceWakeLocaleID"
let voiceWakeAdditionalLocalesKey = "openhoof.voiceWakeAdditionalLocaleIDs"
let voicePushToTalkEnabledKey = "openhoof.voicePushToTalkEnabled"
let talkEnabledKey = "openhoof.talkEnabled"
let iconOverrideKey = "openhoof.iconOverride"
let connectionModeKey = "openhoof.connectionMode"
let remoteTargetKey = "openhoof.remoteTarget"
let remoteIdentityKey = "openhoof.remoteIdentity"
let remoteProjectRootKey = "openhoof.remoteProjectRoot"
let remoteCliPathKey = "openhoof.remoteCliPath"
let canvasEnabledKey = "openhoof.canvasEnabled"
let cameraEnabledKey = "openhoof.cameraEnabled"
let systemRunPolicyKey = "openhoof.systemRunPolicy"
let systemRunAllowlistKey = "openhoof.systemRunAllowlist"
let systemRunEnabledKey = "openhoof.systemRunEnabled"
let locationModeKey = "openhoof.locationMode"
let locationPreciseKey = "openhoof.locationPreciseEnabled"
let peekabooBridgeEnabledKey = "openhoof.peekabooBridgeEnabled"
let deepLinkKeyKey = "openhoof.deepLinkKey"
let modelCatalogPathKey = "openhoof.modelCatalogPath"
let modelCatalogReloadKey = "openhoof.modelCatalogReload"
let cliInstallPromptedVersionKey = "openhoof.cliInstallPromptedVersion"
let heartbeatsEnabledKey = "openhoof.heartbeatsEnabled"
let debugPaneEnabledKey = "openhoof.debugPaneEnabled"
let debugFileLogEnabledKey = "openhoof.debug.fileLogEnabled"
let appLogLevelKey = "openhoof.debug.appLogLevel"
let voiceWakeSupported: Bool = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
