import gleam/bitwise.{shift_left}
import gleam/list

/// Enum for easy creation of discord intents for bots
pub type Intent {
  /// ## Events:
  /// - GUILD_CREATE (`on_guild_create`)
  /// - GUILD_UPDATE (`on_guild_update`)
  /// - GUILD_DELETE (`on_guild_delete`)
  /// - GUILD_ROLE_CREATE (`on_guild_role_create`)
  /// - GUILD_ROLE_UPDATE (`on_guild_role_update`)
  /// - GUILD_ROLE_DELETE (`on_guild_role_delete`)
  /// - CHANNEL_CREATE (`on_channel_create`)
  /// - CHANNEL_UPDATE (`on_channel_update`)
  /// - CHANNEL_DELETE (`on_channel_delete`)
  /// - CHANNEL_PINS_UPDATE (`on_channel_pins_update`)
  /// - THREAD_CREATE (`on_thread_create`)
  /// - THREAD_UPDATE (`on_thread_update`)
  /// - THREAD_DELETE (`on_thread_delete`)
  /// - THREAD_LIST_SYNC (`on_thread_list_sync`)
  /// - THREAD_MEMBER_UPDATE (`on_thread_member_update`)
  /// - THREAD_MEMBERS_UPDATE (`on_thread_members_update`)
  /// - STAGE_INSTANCE_CREATE (`on_stage_instance_create`)
  /// - STAGE_INSTANCE_UPDATE (`on_stage_instance_update`)
  /// - STAGE_INSTANCE_DELETE (`on_stage_instance_delete`)
  /// ## Intents:
  /// Represented as 1 << 0
  Guilds
  /// ## Events:
  /// - GUILD_MEMBER_ADD (`on_guild_member_add`)
  /// - GUILD_MEMBER_UPDATE (`on_guild_member_update`)
  /// - GUILD_MEMBER_REMOVE (`on_guild_member_remove`)
  /// - THREAD_MEMBERS_UPDATE (`on_thread_members_update`)
  /// ## Intents:
  /// Represented as 1 << 1
  GuildMembers
  /// ## Events:
  /// - GUILD_BAN_ADD (`on_guild_ban_add`)
  /// - GUILD_BAN_REMOVE (`on_guild_ban_remove`)
  /// ## Intents:
  /// Represented as 1 << 2
  GuildBans
  /// ## Events:
  /// - GUILD_EMOJIS_UPDATE (`on_guild_emojis_update`)
  /// - GUILD_STICKERS_UPDATE (`on_guild_stickers_update`)
  /// ## Intents:
  /// Represented as 1 << 3
  GuildEmojisAndStickers
  /// ## Events:
  /// - GUILD_INTEGRATIONS_UPDATE (`on_guild_integrations_update`)
  /// - INTEGRATION_CREATE (`on_integration_create`)
  /// - INTEGRATION_UPDATE (`on_integration_update`)
  /// - INTEGRATION_DELETE (`on_integration_delete`)
  /// ## Intents:
  /// Represented as 1 << 4
  GuildIntegrations
  /// ## Events:
  /// - WEBHOOKS_UPDATE (`on_webhooks_update`)
  /// ## Intents:
  /// Represented as 1 << 5
  GuildWebhooks
  /// ## Events:
  /// - INVITE_CREATE (`on_invite_create`)
  /// - INVITE_DELETE (`on_invite_delete`)
  /// ## Intents:
  /// Represented as 1 << 6
  GuildInvites
  /// ## Events:
  /// - VOICE_STATE_UPDATE (`on_voice_state_update`)
  /// ## Intents:
  /// Represented as 1 << 7
  GuildVoiceStates
  /// ## Events:
  /// - PRESENCE_UPDATE (`on_presence_update`)
  /// ## Intents:
  /// Represented as 1 << 8
  GuildPresences
  /// ## Events:
  /// - MESSAGE_CREATE (`on_message_create`)
  /// - MESSAGE_UPDATE (`on_message_update`)
  /// - MESSAGE_DELETE (`on_message_delete`)
  /// - MESSAGE_DELETE_BULK (`on_message_delete_bulk`)
  /// ## Intents:
  /// Represented as 1 << 9
  GuildMessages
  /// ## Events:
  /// - MESSAGE_REACTION_ADD (`on_message_reaction_add`)
  /// - MESSAGE_REACTION_REMOVE (`on_message_reaction_remove`)
  /// - MESSAGE_REACTION_REMOVE_ALL (`on_message_reaction_remove_all`)
  /// - MESSAGE_REACTION_REMOVE_EMOJI (`on_message_reaction_remove_emoji`)
  /// ## Intents:
  /// Represented as 1 << 10
  GuildMessageReactions
  /// ## Events:
  /// - TYPING_START (`on_typing_start`)
  /// ## Intents:
  /// Represented as 1 << 11
  GuildMessageTyping
  /// ## Events:
  /// - MESSAGE_CREATE (`on_message_created`)
  /// - MESSAGE_UPDATE (`on_message_updated`)
  /// - MESSAGE_DELETE (`on_message_deleted`)
  /// - CHANNEL_PINS_UPDATE (`on_channel_pins_update`)
  /// ## Intents:
  /// Represented as 1 << 12
  DirectMessages
  /// ## Events:
  /// - MESSAGE_REACTION_ADD (`on_message_reaction_add`)
  /// - MESSAGE_REACTION_REMOVE (`on_message_reaction_remove`)
  /// - MESSAGE_REACTION_REMOVE_ALL (`on_message_reaction_remove_all`)
  /// - MESSAGE_REACTION_REMOVE_EMOJI (`on_message_reaction_remove_emoji`)
  /// ## Intents:
  /// Represented as 1 << 13
  DirectMessageReactions
  /// ## Events:
  /// - TYPING_START (`on_typing_start`)
  /// ## Intents:
  /// Represented as 1 << 14
  DirectMessageTyping
  /// Allows access to the content of messages, used with the `DirectMessages` and `GuildMessages` intents.
  /// ## Intents:
  /// Represented as 1 << 15
  MessageContent
  /// ## Events:
  /// - GUILD_SCHEDULED_EVENT_CREATE (`on_guild_scheduled_event_create`)
  /// - GUILD_SCHEDULED_EVENT_UPDATE (`on_guild_scheduled_event_update`)
  /// - GUILD_SCHEDULED_EVENT_DELETE (`on_guild_scheduled_event_delete`)
  /// - GUILD_SCHEDULED_EVENT_USER_ADD (`on_guild_scheduled_event_user_add`)
  /// - GUILD_SCHEDULED_EVENT_USER_REMOVE (`on_guild_scheduled_event_user_remove`)
  /// ## Intents:
  /// Represented as 1 << 16
  GuildScheduledEvents
  /// ## Events:
  /// - AUTO_MODERATION_RULE_CREATE (`on_auto_moderation_rule_create`)
  /// - AUTO_MODERATION_RULE_UPDATE (`on_auto_moderation_rule_update`)
  /// - AUTO_MODERATION_RULE_DELETE (`on_auto_moderation_rule_delete`)
  /// ## Intents:
  /// Represented as 1 << 20
  GuildAutoModeration
  /// ## Events:
  /// - AUTO_MODERATION_ACTION_EXECUTION (`on_auto_moderation_action_execution`)
  /// ## Intents:
  /// Represented as 1 << 21
  GuildAutoModerationExecution
}

pub fn intent_to_int(intent: Intent) -> Int {
  case intent {
    Guilds ->
      1
      |> shift_left(0)
    GuildMembers ->
      1
      |> shift_left(1)
    GuildBans ->
      1
      |> shift_left(2)
    GuildEmojisAndStickers ->
      1
      |> shift_left(3)
    GuildIntegrations ->
      1
      |> shift_left(4)
    GuildWebhooks ->
      1
      |> shift_left(5)
    GuildInvites ->
      1
      |> shift_left(6)
    GuildVoiceStates ->
      1
      |> shift_left(7)
    GuildPresences ->
      1
      |> shift_left(8)
    GuildMessages ->
      1
      |> shift_left(9)
    GuildMessageReactions ->
      1
      |> shift_left(10)
    GuildMessageTyping ->
      1
      |> shift_left(11)
    DirectMessages ->
      1
      |> shift_left(12)
    DirectMessageReactions ->
      1
      |> shift_left(13)
    DirectMessageTyping ->
      1
      |> shift_left(14)
    MessageContent ->
      1
      |> shift_left(15)
    GuildScheduledEvents ->
      1
      |> shift_left(16)
    GuildAutoModeration ->
      1
      |> shift_left(20)
    GuildAutoModerationExecution ->
      1
      |> shift_left(21)
  }
}

pub fn intents_to_int(intents: List(Intent)) -> Int {
  intents
  |> list.map(intent_to_int)
  |> list.fold(0, fn(a, b) { bitwise.or(a, b) })
}

/// All intents except for `GuildPresences` `GuildMembers` `MessageContent`
pub fn unprivileged() -> List(Intent) {
  [
    Guilds,
    GuildBans,
    GuildEmojisAndStickers,
    GuildIntegrations,
    GuildWebhooks,
    GuildInvites,
    GuildVoiceStates,
    GuildMessages,
    GuildMessageReactions,
    GuildMessageTyping,
    DirectMessages,
    DirectMessageReactions,
    DirectMessageTyping,
    GuildScheduledEvents,
    GuildAutoModeration,
    GuildAutoModerationExecution,
  ]
}

/// All intents
pub fn all() -> List(Intent) {
  [
    Guilds,
    GuildMembers,
    GuildBans,
    GuildEmojisAndStickers,
    GuildIntegrations,
    GuildWebhooks,
    GuildInvites,
    GuildVoiceStates,
    GuildPresences,
    GuildMessages,
    GuildMessageReactions,
    GuildMessageTyping,
    DirectMessages,
    DirectMessageReactions,
    DirectMessageTyping,
    MessageContent,
    GuildScheduledEvents,
    GuildAutoModeration,
    GuildAutoModerationExecution,
  ]
}

/// The default intents enabled, limited to recieved the least data required
/// ## Intents:
/// - Guilds
pub fn default() -> List(Intent) {
  [Guilds]
}
