#!/bin/bash

LOOP=${LOOP:='yes'}
CPU_PERCENTAGE_UPPER_LIMIT=85
CPU_PERCENTAGE_LOWER_LIMIT=25
PROMETHEUS_API="api/v1/query?query="
PROMETHEUS_QUERY="sum(rate(container_cpu_usage_seconds_total%7Bcontainer_label_com_docker_swarm_task_name%3D~%27.%2B%27%7D%5B5m%5D))BY(container_label_com_docker_swarm_service_name%2Cinstance)*100"

get_high_cpu_services () {
  local prometheus_results="${1}"
  local services=""
  for service in $(printf "%s$prometheus_results" | jq ".data.result[] | select( all(.value[1]|tonumber; . > $CPU_PERCENTAGE_UPPER_LIMIT) ) | .metric.container_label_com_docker_swarm_service_name" | sed 's/"//g' | sort | uniq); do
    services="$services $service"
  done
  echo $services
}

get_all_services () {
  local prometheus_results="${1}"
  local services=""
  for service in $(printf "%s$prometheus_results" | jq ".data.result[].metric.container_label_com_docker_swarm_service_name" | sed 's/"//g' | sort | uniq); do
    services="$services $service"
  done
  echo $services
}

get_low_cpu_services () {
  local prometheus_results="${1}"
  local services=""
  for service in $(printf "%s$prometheus_results" | jq ".data.result[] | select( all(.value[1]|tonumber; . < $CPU_PERCENTAGE_LOWER_LIMIT) ) | .metric.container_label_com_docker_swarm_service_name" | sed 's/"//g' | sort | uniq); do
    services="$services $service"
  done
  echo $services
}

default_scale () {
  service_name=$1
  auto_scale_label=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler"]')
  replica_minimum=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler.minimum"]' | sed 's/\"//g')
  replica_maximum=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler.maximum"]' | sed 's/\"//g')
  if [[ "${auto_scale_label}" == "\"true\"" ]]; then
    echo Service $service has an autoscale label.
    current_replicas=$(docker service inspect $service_name | jq ".[].Spec.Mode.Replicated | .Replicas")
    if [[ $replica_minimum -gt $current_replicas ]]; then
      echo Service $service_name is below the minimum. Scaling to the minimum of $replica_minimum
      docker service scale $service_name=$replica_minimum
    elif [[ $current_replicas -gt $replica_maximum ]]; then
      echo Service $service_name is above the maximum. Scaling to the maximum of $replica_maximum
      docker service scale $service_name=$replica_maximum
    fi
  else
    echo Service $service does not have an autoscale label.
  fi

}

scale_down () {
  service_name=$1
  auto_scale_label=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler"]')
  replica_minimum=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler.minimum"]' | sed 's/\"//g')
  if [[ "${auto_scale_label}" == "\"true\"" ]]; then
    current_replicas=$(docker service inspect $service_name | jq ".[].Spec.Mode.Replicated | .Replicas")
    new_replicas=$(expr $current_replicas - 1)
    if [[ $replica_minimum -le $new_replicas ]]; then
      echo Scaling down the service $service_name to $new_replicas
      docker service scale $service_name=$new_replicas
    elif [[ $current_replicas -eq $replica_minimum ]]; then
      echo Service $service_name has the minumum number of replicas.
    fi
  fi

}

scale_up () {
  service_name=$1
  auto_scale_label=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler"]')
  replica_maximum=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler.maximum"]' | sed 's/\"//g')
  if [[ "${auto_scale_label}" == "\"true\"" ]]; then
    current_replicas=$(docker service inspect $service_name | jq ".[].Spec.Mode.Replicated | .Replicas")
    new_replicas=$(expr $current_replicas + 1)
    if [[ $current_replicas -eq $replica_maximum ]]; then
      echo Service $service already has the maximum of $replica_maximum replicas
    elif [[ $replica_maximum -ge $new_replicas ]]; then
      echo Scaling up the service $service_name to $new_replicas
      docker service scale $service_name=$new_replicas
    fi
  fi
}

main () {
    prometheus_initial_results=$(curl --silent "${PROMETHEUS_URL}/${PROMETHEUS_API}${PROMETHEUS_QUERY}" | jq .)
    echo Prometheus results
    echo $prometheus_initial_results
    for service in $(get_all_services "${prometheus_initial_results}"); do
      default_scale $service
    done
    echo Checking for high cpu services
    for service in $(get_high_cpu_services "${prometheus_initial_results}"); do
      echo Service $service is above $CPU_PERCENTAGE_UPPER_LIMIT percent cpu usage.
      scale_up $service
    done
    echo Checking for low cpu services
    for service in $(get_low_cpu_services "${prometheus_initial_results}"); do
      echo Service $service is below $CPU_PERCENTAGE_LOWER_LIMIT percent cpu usage.
      scale_down $service  
    done
}

main
while [[ $LOOP == 'yes' ]]; do
  echo Waiting 60 seconds for the next test
  sleep 60s
  main
done