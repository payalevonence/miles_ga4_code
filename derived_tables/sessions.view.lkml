# If necessary, uncomment the line below to include explore_source.
# include: "miles-partnership.model.lkml"

view: sessions {
  derived_table: {
    explore_source: events {
      column: unique_session_id {}
      column: first_event {}
      column: last_event {}
      column: user_pseudo_id {}
      column: landing_page {}
      derived_column: previous_session_timestamp {
        sql: lag(last_event) over (partition by user_pseudo_id order by first_event asc);;
        }
      bind_all_filters: yes
    }
  }
  dimension: unique_session_id {
    hidden: yes
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
  dimension: landing_page {
    type: string
    sql: ${TABLE}.landing_page ;;
  }
  dimension_group: session {
    type: duration
    sql_start: ${session_start_raw} ;;
    sql_end: ${session_end_raw} ;;
    intervals: [second, minute, hour, day]
  }
  dimension_group: previous_session {
    hidden: yes
    type: time
    timeframes: [raw]
    sql: ${TABLE}.previous_session_timestamp ;;
  }
  dimension_group: since_previous_session {
    type: duration
    intervals: [minute, hour, day]
    sql_start: ${previous_session_raw} ;;
    sql_end: ${session_end_raw} ;;
  }
  dimension: session_duration_tier {
    group_label: "Duration Session"
    label: "Session Duration Tiers"
    description: "The length (returned as a string) of a session measured in seconds and reported in second increments."
    type: tier
    sql: ${seconds_session} ;;
    tiers: [10,30,60,120,180,240,300,600]
    style: integer
  }
  dimension: is_bounce {
    type: yesno
    sql: ${seconds_session} < 30 ;;
  }
  measure: average_session_duration_mins {
    label: "Average Session Duration (mins)"
    type: average
    sql: ${minutes_session} ;;
    value_format_name: decimal_1
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
