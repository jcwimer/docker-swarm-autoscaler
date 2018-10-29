CPU_PERCENTAGE_UPPER_LIMIT=85
CPU_PERCENTAGE_LOWER_LIMIT=25
PROMETHEUS_API="api/v1/query?query="
PROMETHEUS_QUERY="sum(rate(container_cpu_usage_seconds_total%7Bcontainer_label_com_docker_swarm_task_name%3D~%27.%2B%27%7D%5B5m%5D))BY(container_label_com_docker_swarm_service_name%2Cinstance)*100"

while ls > /dev/null; do
  #scale up
  for service in $(curl --silent "${PROMETHEUS_URL}/${PROMETHEUS_API}${PROMETHEUS_QUERY}>${CPU_PERCENTAGE_UPPER_LIMIT}" | jq ".data.result[].metric | .container_label_com_docker_swarm_service_name" | sort | uniq); do
    service_name=$(echo $service | sed 's/\"//g')
    auto_scale_label=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler"]')
    replica_maximum=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler.maximum"]' | sed 's/\"//g')
    if [[ "${auto_scale_label}" == "\"true\"" ]]; then
      current_replicas=$(docker service inspect $service_name | jq ".[].Spec.Mode.Replicated | .Replicas")
      new_replicas=$(expr $current_replicas + 1)
      if [[ $replica_maximum -ge $new_replicas ]]; then
        echo scale up $service_name to $new_replicas
        docker service scale $service_name=$new_replicas
      fi
    fi
  done

  #scale down
  for service in $(curl --silent "${PROMETHEUS_URL}${PROMETHEUS_API}${PROMETHEUS_QUERY}<${CPU_PERCENTAGE_LOWER_LIMIT}" | jq ".data.result[].metric | .container_label_com_docker_swarm_service_name" | sort | uniq); do
    service_name=$(echo $service | sed 's/\"//g')
    auto_scale_label=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler"]')
    replica_minimum=$(docker service inspect $service_name | jq '.[].Spec.Labels["swarm.autoscaler.minimum"]' | sed 's/\"//g')
    if [[ "${auto_scale_label}" == "\"true\"" ]]; then
      current_replicas=$(docker service inspect $service_name | jq ".[].Spec.Mode.Replicated | .Replicas")
      new_replicas=$(expr $current_replicas - 1)
      if [[ $replica_minimum -le $new_replicas ]]; then
        echo scale down $service_name to $new_replicas
        docker service scale $service_name=$new_replicas
      fi
    fi
  done
done
