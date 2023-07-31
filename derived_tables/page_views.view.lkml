# If necessary, uncomment the line below to include explore_source.
# include: "miles-partnership.model.lkml"

view: page_views {
  view_label: "Events"
  derived_table: {
    explore_source: events {
      column: _event_time {}
      column: event_id {}
      column: page {}
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
      derived_column: current_page_minus_1 {
        sql: lag(page,1) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_minus_2 {
        sql: lag(page,2) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_minus_3 {
        sql: lag(page,3) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_minus_4 {
        sql: lag(page,4) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_minus_5 {
        sql: lag(page,5) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_minus_6 {
        sql: lag(page,6) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_minus_7 {
        sql: lag(page,7) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_minus_8 {
        sql: lag(page,8) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_minus_9 {
        sql: lag(page,9) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_1 {
        sql: lead(page,1) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_2 {
        sql: lead(page,2) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_3 {
        sql: lead(page,3) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_4 {
        sql: lead(page,4) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_5 {
        sql: lead(page,5) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_6 {
        sql: lead(page,6) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_7 {
        sql: lead(page,7) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_8 {
        sql: lead(page,8) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_page_plus_9 {
        sql: lead(page,9) over (partition by unique_session_id order by _event_time asc) ;;
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
  dimension: current_page_minus_1 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 1 pages before current page."
  }
  dimension: current_page_minus_2 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 2 pages before current page."
  }
  dimension: current_page_minus_3 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 3 pages before current page."
  }
  dimension: current_page_minus_4 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 4 pages before current page."
  }
  dimension: current_page_minus_5 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 5 pages before current page."
  }
  dimension: current_page_minus_6 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 6 pages before current page."
  }
  dimension: current_page_minus_7 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 7 pages before current page."
  }
  dimension: current_page_minus_8 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 8 pages before current page."
  }
  dimension: current_page_minus_9 {
    view_label: "Page Flow"
    group_label: "Reverse Path Path"
    description: "Page Path for page that came 9 pages before current page."
  }
  dimension: current_page_plus_1 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 1 pages after current page."
  }
  dimension: current_page_plus_2 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 2 pages after current page."
  }
  dimension: current_page_plus_3 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 3 pages after current page."
  }
  dimension: current_page_plus_4 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 4 pages after current page."
  }
  dimension: current_page_plus_5 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 5 pages after current page."
  }
  dimension: current_page_plus_6 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 6 pages after current page."
  }
  dimension: current_page_plus_7 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 7 pages after current page."
  }
  dimension: current_page_plus_8 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 8 pages after current page."
  }
  dimension: current_page_plus_9 {
    view_label: "Page Flow"
    group_label: "Relative Page Path"
    description: "Page Path for page that came 9 pages after current page."
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
  dimension: is_bounce {
    description: "If this pageview was the only pageview or screenview hit of a session, this is set to true."
    type: yesno
    sql: ${sessions.count_of_page_views} = 1 ;;
  }
  measure: total_bounces {
    hidden: yes
    type: count
    filters: [is_bounce: "yes"]
  }
  measure: bounce_rate {
    group_label: "Page"
    label: "Page View Bounce Rate"
    description: "The percentage of page views that are from sessions where only 1 page was viewed"
    type: number
    sql: ${total_bounces}/nullif(${events.count_of_page_views},0) ;;
    value_format_name: percent_2
  }
  measure: total_exits {
    type: count
    description: "The number of exits from the property."
    filters: [page_view_rank_desc: "1"]
  }
  measure: total_entrances {
    type: count
    description: "The number of entrances to the property measured as the first pageview in a session, typically used with Landing Page."
    filters: [page_view_rank_asc: "1"]
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
