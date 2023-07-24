# If necessary, uncomment the line below to include explore_source.
# include: "miles-partnership.model.lkml"

view: events_dt {
  view_label: "Events"
  derived_table: {
    explore_source: events {
      column: event_id {}
      column: _event_time {}
      column: unique_session_id {}
      bind_all_filters: yes
      derived_column: event_rank_asc {
        sql: rank() over (partition by unique_session_id order by _event_time asc) ;;
      }
    }
  }
  dimension: event_id {
    primary_key: yes
    hidden: yes
  }
  dimension: event_rank_asc {
    label: "Event Rank"
    description: "The order of an event within this session (ie. 1 = first event in a session)"
    type: number
  }
}
