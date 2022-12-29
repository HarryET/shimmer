import gleam/option.{None, Option, Some}
import shimmer/types/presence.{
  PresenceActivity, PresenceActivityAssets, PresenceActivityButton,
  PresenceActivityFlags, PresenceActivityParty, PresenceActivitySecrets,
  PresenceActivityTimestamps, PresenceActivityType,
}
import shimmer/types/emoji.{Emoji}
import shimmer/internal/error

pub type PresenceActivityBuilder {
  PresenceActivityBuilder(
    name: String,
    type_: PresenceActivityType,
    url: Option(String),
    created_at: Option(Int),
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

pub fn new(name: String, type_: PresenceActivityType) -> PresenceActivityBuilder {
  PresenceActivityBuilder(
    name,
    type_,
    url: None,
    created_at: None,
    timestamps: None,
    application_id: None,
    details: None,
    state: None,
    emoji: None,
    party: None,
    assets: None,
    secrets: None,
    instance: None,
    flags: None,
    buttons: None,
  )
}

pub fn build(
  self: PresenceActivityBuilder,
) -> Result(PresenceActivity, error.ShimmerError) {
  // TODO validate properties based on type e.g. streaming requires a url

  Ok(PresenceActivity(
    name: self.name,
    type_: self.type_,
    url: self.url,
    created_at: self.created_at
    |> option.unwrap(or: 1),
    timestamps: self.timestamps,
    application_id: self.application_id,
    details: self.details,
    state: self.state,
    emoji: self.emoji,
    party: self.party,
    assets: self.assets,
    secrets: self.secrets,
    instance: self.instance,
    flags: self.flags,
    buttons: self.buttons,
  ))
}

pub fn set_name(
  self: PresenceActivityBuilder,
  name: String,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, name: name)
}

pub fn set_type(
  self: PresenceActivityBuilder,
  type_: PresenceActivityType,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, type_: type_)
}

pub fn set_url(
  self: PresenceActivityBuilder,
  url: String,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, url: Some(url))
}

pub fn set_created_at(
  self: PresenceActivityBuilder,
  created_at: Int,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, created_at: Some(created_at))
}

pub fn set_timestamps(
  self: PresenceActivityBuilder,
  timestamps: PresenceActivityTimestamps,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, timestamps: Some(timestamps))
}

pub fn set_application_id(
  self: PresenceActivityBuilder,
  application_id: String,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, application_id: Some(application_id))
}

pub fn set_details(
  self: PresenceActivityBuilder,
  details: String,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, details: Some(details))
}

pub fn set_state(
  self: PresenceActivityBuilder,
  state: String,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, state: Some(state))
}

pub fn set_emoji(
  self: PresenceActivityBuilder,
  emoji: Emoji,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, emoji: Some(emoji))
}

pub fn set_party(
  self: PresenceActivityBuilder,
  party: PresenceActivityParty,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, party: Some(party))
}

pub fn set_assets(
  self: PresenceActivityBuilder,
  assets: PresenceActivityAssets,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, assets: Some(assets))
}

pub fn set_secrets(
  self: PresenceActivityBuilder,
  secrets: PresenceActivitySecrets,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, secrets: Some(secrets))
}

pub fn set_instance(
  self: PresenceActivityBuilder,
  instance: Bool,
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, instance: Some(instance))
}

pub fn set_flags(
  self: PresenceActivityBuilder,
  flags: List(PresenceActivityFlags),
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, flags: Some(flags))
}

pub fn add_flag(
  self: PresenceActivityBuilder,
  flag: PresenceActivityFlags,
) -> PresenceActivityBuilder {
  let new_flags = case self.flags {
    Some(flags) -> [flag, ..flags]
    None -> [flag]
  }

  PresenceActivityBuilder(..self, flags: Some(new_flags))
}

pub fn set_buttons(
  self: PresenceActivityBuilder,
  buttons: List(PresenceActivityButton),
) -> PresenceActivityBuilder {
  PresenceActivityBuilder(..self, buttons: Some(buttons))
}

pub fn add_button(
  self: PresenceActivityBuilder,
  button: PresenceActivityButton,
) -> PresenceActivityBuilder {
  let new_buttons = case self.buttons {
    Some(buttons) -> [button, ..buttons]
    None -> [button]
  }

  PresenceActivityBuilder(..self, buttons: Some(new_buttons))
}
