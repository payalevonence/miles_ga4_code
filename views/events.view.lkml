
view: events {
  sql_table_name: `miles-partnership-ga4.analytics_{% parameter profile %}.events_*` ;;

  parameter: profile {
    type: unquoted
    allowed_value: {
      label: "occroadhouse"
      value: "269520886"
    }
    allowed_value: {
      label: "alaskatia"
      value: "347778234"
    }
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: event_params {
    hidden: yes
    sql: ${TABLE}.event_params ;;
  }

  dimension: ga_session_number {
    label: "GA Session Number"
    type: number
    sql: (SELECT value.int_value FROM ${event_params} where key='ga_session_number') ;;
  }

  dimension: ga_session_id {
    hidden: yes
    label: "GA Session ID"
    type: string
    sql: CAST((SELECT value.int_value FROM ${event_params} where key='ga_session_id') AS STRING) ;;
  }

  dimension: unique_session_id {
    type: string
    sql: concat(${ga_session_id}, ${user_pseudo_id}) ;;
  }

  dimension: page_title {
    type: string
    sql: (SELECT value.string_value FROM ${event_params} where key='page_title') ;;
  }

  dimension_group: event {
    type: time
    timeframes: [date, week, day_of_week, month, year]
    sql: TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'\d\d\d\d\d\d\d\d'))) ;;
  }

  dimension_group: _event {
    label: "Event"
    timeframes: [raw,time,hour,minute]
    type: time
    sql: TIMESTAMP_MICROS(${TABLE}.event_timestamp) ;;
  }

  dimension: user_pseudo_id {
    type: string
    sql: ${TABLE}.user_pseudo_id ;;
  }
  measure: count_of_events {
    type: count
  }
  measure: count_of_sessions {
    type: count_distinct
    view_label: "Sessions"
    sql: ${unique_session_id} ;;
  }
  measure: first_event {
    hidden: yes
    type: date_time
    sql: MIN(${_event_raw}) ;;
  }
  measure: last_event {
    hidden: yes
    type: date_time
    sql: MAX(${_event_raw}) ;;
  }
}
