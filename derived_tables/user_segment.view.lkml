view: user_segment {
  derived_table: {
    explore_source: events {
      column: user_pseudo_id {}
      column: count_of_sessions {}
      column: total_purchase_revenue_usd {}
      column: count_of_transactions{}
      bind_filters: {
        from_field: user_segment.user_segment_timeframe
        to_field: events.event_date   #bind filters to filter the table when the view is created
      }
      bind_filters: {
        from_field: user_segment.user_segment_landing_page
        to_field: events.landing_page
      }

    }
  }

  filter: user_segment_timeframe {
    type: date
  }
  filter: user_segment_landing_page {
    type: string
    suggest_explore: events
    suggest_dimension: events.landing_page
  }

  dimension: user_pseudo_id {hidden:yes primary_key:yes}
  dimension: total_sessions {
    hidden: yes
    label: "Sessions Sessions"
    description: "Total Number of Sessions (Count)"
    type: number
    sql: ${TABLE}.count_of_sessions ;;
  }
  dimension: total_purchase_revenue {
    hidden: yes
    label: "Events Purchase Revenue"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}.total_purchase_revenue_usd ;;
  }
  dimension: total_transactions {
    hidden: yes
    label: "Events Transactions"
    type: number
    sql: ${TABLE}.count_of_transactions ;;
  }


  measure: segment_users {
    group_label: "In Selected Timeframe"
    type: count_distinct
    allow_approximate_optimization: yes
    sql: ${user_pseudo_id} ;;
  }

  measure: retention_rate {
    type: number
    sql: ${segment_users}/NULLIF(${events.count_of_users},0) ;;
    value_format_name: percent_1
  }

  measure: segment_sessions {
    group_label: "In Selected Timeframe"
    type: sum
    sql: ${total_sessions} ;;
    value_format_name: decimal_0
  }

  measure: segment_transaction_revenue {
    group_label: "In Selected Timeframe"
    type: sum
    sql: ${total_purchase_revenue} ;;
    value_format_name: usd_0
  }

  measure: segment_transaction_revenue_per_user {
    group_label: "In Selected Timeframe"
    type: number
    sql: ${segment_transaction_revenue}/NULLIF(${segment_users},0) ;;
    value_format_name: usd
  }

  measure: segment_transaction_count {
    group_label: "In Selected Timeframe"
    type: sum
    sql: ${total_transactions} ;;
    value_format_name: decimal_0
  }

  measure: segment_transaction_conversion_rate {
    group_label: "In Selected Timeframe"
    type: number
    sql: ${segment_transaction_count}/NULLIF(${segment_sessions},0) ;;
    value_format_name: percent_1
  }


}
