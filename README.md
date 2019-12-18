# docker-swarm-autoscaler
This project is intended to bring auto service staling to Docker Swarm. This script uses prometheus paired with cadvisor metrics to determine cpu usage. It then uses a manager node to determine if a service wants to be autoscaled and uses a manager node to scale the service.

Currently the project only uses cpu to autoscale. If cpu usage reaches 85% the service will scale up, if it reaches 25% it will scale down.

## Usage
1. You can deploy prometheus, cadvisor, and docker-swarm-autoscaler by running `docker stack deploy -c swarm-autoscaler-stack.yml autoscaler` from the root of this repo.  
  * You can also utilize an already deploy prometheus and cadvisor by specifying the `PROMETHEUS_URL` in docker-swarm-autoscaler environment. `swarm-autoscaler-stack.yml` shows an example of this.  
  * docker-swarm-autoscale needs a placement contstraint to deploy to a manager. `swarm-autoscaler-stack.yml` shows an example of this.  
2. For services you want to autoscale you will need a deploy label `swarm.autoscaler=true`. 

```
deploy:
  labels:
    - "swarm.autoscaler=true"
```

This is best paired with resource constraints limits. This is also under the deploy key.

```
deploy:
  resources:
    reservations:
      cpus: '0.25'
      memory: 512M
    limits:
      cpus: '0.50'
```

## Configuration
| Setting | Value | Description |
| --- | --- | --- |
| `swarm.autoscaler` | `true` | Required. This enables autoscaling for a service. Anything other than `true` will not enable it |
| `swarm.autoscaler.minimum` | Integer | Optional. This is the minimum number of replicas wanted for a service. The autoscaler will not downscale below this number |
| `swarm.autoscaler.maximum` | Integer | Optional. This is the maximum number of replicas wanted for a service. The autoscaler will not scale up past this number | 

## Test
You can deploy a test app with the following commands below. Helloworld is initially only 1 replica. The autoscaler will scale to the minimum 3 replicas.
1. `docker stack deploy -c swarm-autoscaler-stack.yml autoscaler`
2. `docker stack deploy -c helloworld.yml hello`