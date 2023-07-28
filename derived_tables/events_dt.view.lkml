# If necessary, uncomment the line below to include explore_source.
# include: "miles-partnership.model.lkml"

view: events_dt {
  view_label: "Events"
  derived_table: {
    explore_source: events {
      column: event_id {}
      column: _event_time {}
      column: full_event {}
      column: unique_session_id {}
      bind_all_filters: yes
      derived_column: event_rank_asc {
        sql: rank() over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_1 {
        sql: lag(full_event,1) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_2 {
        sql: lag(full_event,2) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_3 {
        sql: lag(full_event,3) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_4 {
        sql: lag(full_event,4) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_5 {
        sql: lag(full_event,5) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_6 {
        sql: lag(full_event,6) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_7 {
        sql: lag(full_event,7) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_8 {
        sql: lag(full_event,8) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_minus_9 {
        sql: lag(full_event,9) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_1 {
        sql: lead(full_event,1) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_2 {
        sql: lead(full_event,2) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_3 {
        sql: lead(full_event,3) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_4 {
        sql: lead(full_event,4) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_5 {
        sql: lead(full_event,5) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_6 {
        sql: lead(full_event,6) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_7 {
        sql: lead(full_event,7) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_8 {
        sql: lead(full_event,8) over (partition by unique_session_id order by _event_time asc) ;;
      }
      derived_column: current_event_plus_9 {
        sql: lead(full_event,9) over (partition by unique_session_id order by _event_time asc) ;;
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
  dimension: current_event_minus_1 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 1 Events before current Event."
  }
  dimension: current_event_minus_2 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 2 Events before current Event."
  }
  dimension: current_event_minus_3 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 3 Events before current Event."
  }
  dimension: current_event_minus_4 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 4 Events before current Event."
  }
  dimension: current_event_minus_5 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 5 Events before current Event."
  }
  dimension: current_event_minus_6 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 6 Events before current Event."
  }
  dimension: current_event_minus_7 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 7 Events before current Event."
  }
  dimension: current_event_minus_8 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 8 Events before current Event."
  }
  dimension: current_event_plus_9 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 9 Events before current Event."
  }
  dimension: current_event_plus_1 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 1 Events after current Event."
  }
  dimension: current_event_plus_2 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 2 Events after current Event."
  }
  dimension: current_event_plus_3 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 3 Events after current Event."
  }
  dimension: current_event_plus_4 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 4 Events after current Event."
  }
  dimension: current_event_plus_5 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 5 Events after current Event."
  }
  dimension: current_event_plus_6 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 6 Events after current Event."
  }
  dimension: current_event_plus_7 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 7 Events after current Event."
  }
  dimension: current_event_plus_8 {
    view_label: "Event Flow"
    group_label: "Relative Event Path"
    description: "Event Path for Event that came 8 Events after current Event."
  }
  dimension: current_event_minus_9 {
    view_label: "Event Flow"
    group_label: "Reverse Event Path"
    description: "Event Path for Event that came 9 Events after current Event."
  }
}
