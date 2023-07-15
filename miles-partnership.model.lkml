connection: "looker_views"

include: "/views/*.view.lkml"
include: "/derived_tables/*.view.lkml"

explore: events {
  label: "Google Analytics"
  always_filter: {
    filters: [
      events.event_date: "last 7 days",
      events.profile: "269520886"
      ]
  }

  join: sessions {
    sql_on: ${events.unique_session_id} = ${sessions.unique_session_id} ;;
    relationship: many_to_one
  }
  join: page_views {
    sql_on: ${events.event_id} = ${page_views.event_id} ;;
    relationship: one_to_one
  }
}
