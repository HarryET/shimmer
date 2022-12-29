import gleam/option.{None, Option, Some}
import gleam/bitwise.{shift_left}
import gleam/list
import shimmer/types/emoji.{Emoji}
import gleam/dynamic
import gleam/map.{Map, insert}

/// The status used in a Presence
pub type PresenceStatus {
  /// Online
  Online
  /// Do Not Disturb
  DoNotDisturb
  /// AFK
  Idle
  /// Invisible and shown as offline
  Invisible
  /// Offline
  Offline
}

pub type PresenceActivityType {
  /// Game
  Game
  /// Streaming
  Streaming
  /// Listening to Spotify
  Listening
  /// Custom status
  Custom
  /// Competing in a game
  Competing
}

pub type PresenceActivityTimestamps {
  PresenceActivityTimestamps(start: Option(Int), end: Option(Int))
}

// Needs size: [current_size, max_size] when seralized
pub type PresenceActivityParty {
  PresenceActivityParty(
    id: Option(String),
    max_size: Option(Int),
    current_size: Option(Int),
  )
}

pub type PresenceActivityAssets {
  PresenceActivityAssets(
    large_image: Option(String),
    large_text: Option(String),
    small_image: Option(String),
    small_text: Option(String),
  )
}

pub type PresenceActivitySecrets {
  PresenceActivitySecrets(
    join: Option(String),
    spectate: Option(String),
    match_: Option(String),
  )
}

pub type PresenceActivityFlags {
  Instace
  Join
  Spectate
  JoinRequest
  Sync
  Play
  PartyPrivacyFriends
  PartyPrivacyVoiceChannel
  Embedded
}

pub fn presence_activity_flag_to_int(flag: PresenceActivityFlags) -> Int {
  case flag {
    Instace ->
      1
      |> shift_left(0)
    Join ->
      1
      |> shift_left(1)
    Spectate ->
      1
      |> shift_left(2)
    JoinRequest ->
      1
      |> shift_left(3)
    Sync ->
      1
      |> shift_left(4)
    Play ->
      1
      |> shift_left(5)
    PartyPrivacyFriends ->
      1
      |> shift_left(6)
    PartyPrivacyVoiceChannel ->
      1
      |> shift_left(7)
    Embedded ->
      1
      |> shift_left(8)
  }
}

pub fn presence_activity_flags_to_int(flags: List(PresenceActivityFlags)) -> Int {
  flags
  |> list.map(presence_activity_flag_to_int)
  |> list.fold(0, fn(a, b) { bitwise.or(a, b) })
}

pub type PresenceActivityButton {
  PresenceActivityButton(label: String, url: String)
}

pub type PresenceActivity {
  PresenceActivity(
    name: String,
    type_: PresenceActivityType,
    url: Option(String),
    created_at: Int,
    timestamps: Option(PresenceActivityTimestamps),
    application_id: Option(String),
    details: Option(String),
    state: Option(String),
    emoji: Option(Emoji),
    party: Option(PresenceActivityParty),
    assets: Option(PresenceActivityAssets),
    secrets: Option(PresenceActivitySecrets),
    instance: Option(Bool),
    flags: Option(List(PresenceActivityFlags)),
    buttons: Option(List(PresenceActivityButton)),
  )
}

pub type Presence {
  Presence(
    status: PresenceStatus,
    activities: List(PresenceActivity),
    since: Option(Int),
    afk: Bool,
  )
}

pub fn to_map(self: Presence) -> Map(String, dynamic.Dynamic) {
  let data =
    map.new()
    |> insert("status", dynamic.from(self.status))
    |> insert("since", dynamic.from(self.since))
    |> insert("afk", dynamic.from(self.afk))

  let activities =
    self.activities
    |> list.map(fn(activity) {
      map.new()
      |> insert("name", dynamic.from(activity.name))
      |> insert("type", dynamic.from(activity.type_))
      |> insert("url", dynamic.from(activity.url))
      |> insert("created_at", dynamic.from(activity.created_at))
      |> insert(
        "timestamps",
        case activity.timestamps {
          Some(t) ->
            map.new()
            |> insert("start", dynamic.from(t.start))
            |> insert("end", dynamic.from(t.end))
            |> dynamic.from
          None ->
            Nil
            |> dynamic.from
        },
      )
      |> insert("application_id", dynamic.from(activity.application_id))
      |> insert("details", dynamic.from(activity.details))
      |> insert("state", dynamic.from(activity.state))
      |> insert(
        "emoji",
        case activity.emoji {
          Some(e) ->
            e
            |> emoji.to_map
            |> dynamic.from
          None ->
            Nil
            |> dynamic.from
        },
      )
      |> insert(
        "party",
        case activity.party {
          Some(p) ->
            map.new()
            |> insert("id", dynamic.from(p.id))
            |> insert(
              "size",
              dynamic.from([
                p.current_size
                |> option.unwrap(or: 0),
                p.max_size
                |> option.unwrap(or: 0),
              ]),
            )
            |> dynamic.from
          None ->
            Nil
            |> dynamic.from
        },
      )
      |> insert(
        "assets",
        case activity.assets {
          Some(a) ->
            map.new()
            |> insert("large_image", dynamic.from(a.large_image))
            |> insert("large_text", dynamic.from(a.large_text))
            |> insert("small_image", dynamic.from(a.small_image))
            |> insert("small_text", dynamic.from(a.small_text))
            |> dynamic.from
          None ->
            Nil
            |> dynamic.from
        },
      )
      |> insert(
        "secrets",
        case activity.secrets {
          Some(s) ->
            map.new()
            |> insert("join", dynamic.from(s.join))
            |> insert("spectate", dynamic.from(s.spectate))
            |> insert("match", dynamic.from(s.match_))
            |> dynamic.from
          None ->
            Nil
            |> dynamic.from
        },
      )
      |> insert("instance", dynamic.from(activity.instance))
      |> insert("flags", dynamic.from(activity.flags))
      |> insert(
        "buttons",
        activity.buttons
        |> option.unwrap(or: [])
        |> list.map(fn(button) {
          map.new()
          |> insert("label", dynamic.from(button.label))
          |> insert("url", dynamic.from(button.label))
        })
        |> dynamic.from,
      )
      |> dynamic.from
    })

  data
  |> insert("activities", dynamic.from(activities))
}
