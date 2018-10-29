# autoscale-docker-swarm
This project is intended to bring auto service staling to Docker Swarm. This script uses prometheus paired with cadvisor metrics to determine cpu usage. It then uses a manager node to determine if a service wants to be autoscaled and uses a manager node to scale the service.

## Usage
1. You can deploy prometheus, cadvisor, and docker-swarm-autoscale by running `docker stack deploy -c swarm-autoscale-stack.yml`.
..* You can also utilize an already deploy prometheus and cadvisor by specifying the PROMETHEUS_URL in docker-swarm-autoscale environment. `swarm-autoscale-stack.yml` shows an example of this.
..* docker-swarm-autoscale needs a placement contstraint to deploy to a manager. swarm-autoscale-stack.yml` shows an example of this.
2. For services you want to autoscale you will need a deploy label ```
deploy:
  labels:
    - "cpu.autoscale=true"
```

## Configuration
| Setting | Value | Description |
| --- | --- | --- |
| `cpu.autoscale` | `true` | Required. This enables autoscaling for a service. Anything other than `true` will not enable it |
| `cpu.autoscale.minimum` | Integer | Optional. This is the minimum number of replicas wanted for a service. The autoscaler will not downscale below this number |
| `cpu.autoscale.maximum` | Integer | Optional. This is the maximum number of replicas wanted for a service. The autoscaler will not scale up past this number | 
