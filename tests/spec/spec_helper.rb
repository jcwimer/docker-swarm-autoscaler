require 'ap'
require 'pry'
require 'rspec/shell/expectations'

RSpec.configure do |c|
  c.include Rspec::Shell::Expectations
end

def create_standard_mocks
  let(:stubbed_env) { create_stubbed_env }
  let(:curl_mock) { stubbed_env.stub_command('curl') }
  let(:docker_mock) { stubbed_env.stub_command('docker') }
end

def set_standard_mock_outputs
  # If you have something non standard need to be output, define your output before running this function. Outputs are stacked to stdout with new lines \n. Thus defining your non standard output first will output will be on top.
  # If your non standard mock output is an exit code, define it after this function. Exit codes can be overwritten and whichever is deined last is what the test will use.
  standard_prometheus_output='{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "container_label_com_docker_swarm_service_name": "autoscale_docker-swarm-autoscaler",
          "instance": "10.0.0.6:8080"
        },
        "value": [
          1576602885.053,
          "0.41103154419335"
        ]
      },
      {
        "metric": {
          "container_label_com_docker_swarm_service_name": "hello_helloworld_low_cpu",
          "instance": "10.0.0.6:8080"
        },
        "value": [
          1576602885.053,
          "0.011596642816404852"
        ]
      },
      {
        "metric": {
          "container_label_com_docker_swarm_service_name": "hello_helloworld_too_low_cpu",
          "instance": "10.0.0.6:8080"
        },
        "value": [
          1576602885.053,
          "0.011596642816404852"
        ]
      },
      {
        "metric": {
          "container_label_com_docker_swarm_service_name": "hello_helloworld_high_cpu",
          "instance": "10.0.0.6:8080"
        },
        "value": [
          1576602885.053,
          "86.4"
        ]
      },
      {
        "metric": {
          "container_label_com_docker_swarm_service_name": "hello_helloworld_high_cpu_full_replicas",
          "instance": "10.0.0.6:8080"
        },
        "value": [
          1576602885.053,
          "86.4"
        ]
      },
      {
        "metric": {
          "container_label_com_docker_swarm_service_name": "hello_helloworld_min_replicas_low_cpu",
          "instance": "10.0.0.6:8080"
        },
        "value": [
          1576602885.053,
          "0.01"
        ]
      },
      {
        "metric": {
          "container_label_com_docker_swarm_service_name": "hello_helloworld_high_cpu_too_many_replicas",
          "instance": "10.0.0.6:8080"
        },
        "value": [
          1576602885.053,
          "86.4"
        ]
      }
    ]
  }
}
' 
  helloworld_high_cpu_too_many_replicas_docker_inspect_output='[
    {
        "Spec": {
            "Name": "hello_helloworld_high_cpu_too_many_replicas",
            "Labels": {
                "com.docker.stack.image": "tutum/hello-world",
                "com.docker.stack.namespace": "hello",
                "swarm.autoscaler": "true",
                "swarm.autoscaler.maximum": "4",
                "swarm.autoscaler.minimum": "3"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 5
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 8080,
                        "PublishMode": "ingress"
                    }
                ]
            }
        }
    }
]'
  helloworld_high_cpu_docker_inspect_output='[
    {
        "Spec": {
            "Name": "hello_helloworld_high_cpu",
            "Labels": {
                "com.docker.stack.image": "tutum/hello-world",
                "com.docker.stack.namespace": "hello",
                "swarm.autoscaler": "true",
                "swarm.autoscaler.maximum": "4",
                "swarm.autoscaler.minimum": "3"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 3
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 8080,
                        "PublishMode": "ingress"
                    }
                ]
            }
        }
    }
]'
  helloworld_high_cpu_full_replicas_docker_inspect_output='[
    {
        "Spec": {
            "Name": "hello_helloworld_high_cpu_full_replicas",
            "Labels": {
                "com.docker.stack.image": "tutum/hello-world",
                "com.docker.stack.namespace": "hello",
                "swarm.autoscaler": "true",
                "swarm.autoscaler.maximum": "4",
                "swarm.autoscaler.minimum": "3"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 4
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 8080,
                        "PublishMode": "ingress"
                    }
                ]
            }
        }
    }
]'
  helloworld_low_cpu_docker_inspect_output='[
    {
        "Spec": {
            "Name": "hello_helloworld_low_cpu",
            "Labels": {
                "com.docker.stack.image": "tutum/hello-world",
                "com.docker.stack.namespace": "hello",
                "swarm.autoscaler": "true",
                "swarm.autoscaler.maximum": "4",
                "swarm.autoscaler.minimum": "3"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 4
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 8080,
                        "PublishMode": "ingress"
                    }
                ]
            }
        }
    }
]'
  helloworld_too_low_cpu_docker_inspect_output='[
    {
        "Spec": {
            "Name": "hello_helloworld_too_low_cpu",
            "Labels": {
                "com.docker.stack.image": "tutum/hello-world",
                "com.docker.stack.namespace": "hello",
                "swarm.autoscaler": "true",
                "swarm.autoscaler.maximum": "4",
                "swarm.autoscaler.minimum": "3"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 1
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 8080,
                        "PublishMode": "ingress"
                    }
                ]
            }
        }
    }
]'
  docker_swarm_autoscaler_docker_inspect_output='[
    {
        "Spec": {
            "Name": "autoscale_docker-swarm-autoscaler",
            "Labels": {
                "com.docker.stack.image": "tutum/hello-world",
                "com.docker.stack.namespace": "autoscale"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 1
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 8080,
                        "PublishMode": "ingress"
                    }
                ]
            }
        }
    }
]'
  hello_helloworld_min_replicas_low_cpu_docker_inspect_output='[
    {
        "Spec": {
            "Name": "hello_helloworld_min_replicas_low_cpu",
            "Labels": {
                "com.docker.stack.image": "tutum/hello-world",
                "com.docker.stack.namespace": "hello",
                "swarm.autoscaler": "true",
                "swarm.autoscaler.maximum": "4",
                "swarm.autoscaler.minimum": "3"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 3
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 8080,
                        "PublishMode": "ingress"
                    }
                ]
            }
        }
    }
]'
  curl_mock.with_args('--silent').outputs(standard_prometheus_output, to: :stdout)
  docker_mock.with_args('service','inspect','hello_helloworld_high_cpu').outputs(helloworld_high_cpu_docker_inspect_output, to: :stdout)
  docker_mock.with_args('service','inspect','hello_helloworld_low_cpu').outputs(helloworld_low_cpu_docker_inspect_output, to: :stdout)
  
  docker_mock.with_args('service','inspect','hello_helloworld_too_low_cpu').outputs(helloworld_too_low_cpu_docker_inspect_output, to: :stdout)
  docker_mock.with_args('service','inspect','autoscale_docker-swarm-autoscaler').outputs(docker_swarm_autoscaler_docker_inspect_output, to: :stdout)
  docker_mock.with_args('service','inspect','hello_helloworld_high_cpu_full_replicas').outputs(helloworld_high_cpu_full_replicas_docker_inspect_output, to: :stdout)
  docker_mock.with_args('service','inspect','hello_helloworld_high_cpu_too_many_replicas').outputs(helloworld_high_cpu_too_many_replicas_docker_inspect_output, to: :stdout)
  docker_mock.with_args('service','inspect','hello_helloworld_min_replicas_low_cpu').outputs(hello_helloworld_min_replicas_low_cpu_docker_inspect_output, to: :stdout)

  docker_mock.with_args('service', 'scale').returns_exitstatus(0)
end