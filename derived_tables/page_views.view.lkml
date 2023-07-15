# If necessary, uncomment the line below to include explore_source.
# include: "miles-partnership.model.lkml"

view: page_views {
  view_label: "Events"
  derived_table: {
    explore_source: events {
      column: _event_time {}
      column: event_id {}
      column: unique_session_id {}
      bind_all_filters: yes
      filters: [events.event_name: "page_view"]
      derived_column: page_view_rank_asc {
        sql: rank() over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: page_view_rank_desc {
        sql: rank() over (partition by unique_session_id order by _event_time desc) ;;
      }
      derived_column: time_of_next_page_view {
        sql: lead(_event_time) over (partition by unique_session_id order by _event_time asc) ;;
      }
    }
  }
  dimension: event_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.event_id ;;
  }
  dimension: page_view_rank_asc {
    type: number
    group_label: "Page Path"
    label: "Page View Rank"
    description: "Rank of 'Page View' Event, 1 = First Event"
    sql: ${TABLE}.page_view_rank_asc ;;
  }
  dimension: page_view_rank_desc {
    type: number
    group_label: "Page Path"
    label: "Page View Reverse Rank"
    description: "Reverse Rank of 'Page View' Event, 1 = Last Event"
    sql: ${TABLE}.page_view_rank_desc ;;
  }
  dimension_group: time_of_next_page_view {
    type: time
    timeframes: [raw]
    hidden: yes
    sql: ${TABLE}.time_of_next_page_view ;;
  }
  dimension_group: _event_time {
    type: time
    timeframes: [raw]
    hidden: yes
    sql: ${TABLE}._event_time ;;
  }
  dimension: seconds_to_next_page {
    group_label: "Page Path"
    type: duration_second
    sql_start: ${_event_time_raw} ;;
    sql_end: ${time_of_next_page_view_raw} ;;
    value_format_name: decimal_0
  }
  measure: average_seconds_to_next_page {
    group_label: "Page"
    label: "Average Seconds on Page"
    description: "Avg time a user spent on a specific page. Note that Single Page_View Sessions are excluded from this measure."
    type: average
    sql: coalesce(${seconds_to_next_page},0) ;;
    value_format_name: decimal_0
  }
}
