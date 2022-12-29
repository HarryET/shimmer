import shimmer/types/presence.{Presence, PresenceActivity, PresenceStatus}
import gleam/option.{None, Option, Some}
import shimmer/internal/error
import shimmer/builders/presence_activity_builder.{PresenceActivityBuilder}

pub type PresenceBuilder {
  PresenceBuilder(
    status: Option(PresenceStatus),
    activities: List(PresenceActivity),
    afk: Option(Bool),
    since: Option(Int),
  )
}

pub fn new() -> PresenceBuilder {
  PresenceBuilder(status: None, activities: [], afk: None, since: None)
}

pub fn build(self: PresenceBuilder) -> Result(Presence, error.ShimmerError) {
  Ok(Presence(
    status: self.status
    |> option.unwrap(or: presence.Online),
    activities: self.activities,
    afk: self.afk
    |> option.unwrap(or: False),
    since: self.since,
  ))
}

pub fn set_status(
  self: PresenceBuilder,
  status: PresenceStatus,
) -> PresenceBuilder {
  PresenceBuilder(..self, status: Some(status))
}

pub fn set_afk(self: PresenceBuilder, afk: Bool) -> PresenceBuilder {
  PresenceBuilder(..self, afk: Some(afk))
}

pub fn set_since(self: PresenceBuilder, since: Int) -> PresenceBuilder {
  PresenceBuilder(..self, since: Some(since))
}

pub fn set_activities(
  self: PresenceBuilder,
  activities: List(PresenceActivity),
) -> PresenceBuilder {
  PresenceBuilder(..self, activities: activities)
}

pub fn add_activity(
  self: PresenceBuilder,
  activity: PresenceActivity,
) -> PresenceBuilder {
  PresenceBuilder(..self, activities: [activity, ..self.activities])
}

pub fn add_activity_from_builder(
  self: PresenceBuilder,
  activity_builder: PresenceActivityBuilder,
) -> Result(PresenceBuilder, error.ShimmerError) {
  try activity =
    activity_builder
    |> presence_activity_builder.build()
  Ok(PresenceBuilder(..self, activities: [activity, ..self.activities]))
}
