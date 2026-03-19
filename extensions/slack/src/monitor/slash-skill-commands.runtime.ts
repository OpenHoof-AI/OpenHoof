import { listSkillCommandsForAgents as listSkillCommandsForAgentsImpl } from "openhoof/plugin-sdk/reply-runtime";

type ListSkillCommandsForAgents =
  typeof import("openhoof/plugin-sdk/reply-runtime").listSkillCommandsForAgents;

export function listSkillCommandsForAgents(
  ...args: Parameters<ListSkillCommandsForAgents>
): ReturnType<ListSkillCommandsForAgents> {
  return listSkillCommandsForAgentsImpl(...args);
}
