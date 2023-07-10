# If necessary, uncomment the line below to include explore_source.
# include: "miles-partnership.model.lkml"

view: sessions {
  derived_table: {
    explore_source: events {
      column: unique_session_id {}
      column: first_event {}
      column: last_event {}
      bind_all_filters: yes
    }
  }
  dimension: unique_session_id {
    primary_key: yes
    label: "Events GA Session ID"
  }
  dimension_group: session_start {
    type: time
    sql: ${TABLE}.first_event ;;
  }
  dimension_group: session_end {
    type: time
    sql: ${TABLE}.last_event ;;
  }
  dimension_group: session {
    type: duration
    sql_start: ${session_start_raw} ;;
    sql_end: ${session_end_raw} ;;
    intervals: [second, minute]
  }
  dimension: is_bounce {
    type: yesno
    sql: ${minutes_session} < 1 ;;
  }
  measure: average_session_duration_mins {
    label: "Average Session Duration (Mins)"
    type: average
    sql: ${minutes_session} ;;
    value_format_name: decimal_0
  }
  measure: count_of_bounced_sessions {
    hidden: no
    type: count
    filters: [is_bounce: "Yes"]
  }
  measure: bounce_rate {
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${count_of_bounced_sessions}/nullif(${events.count_of_sessions},0) ;;
  }
}
