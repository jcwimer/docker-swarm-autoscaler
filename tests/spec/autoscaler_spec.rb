require 'spec_helper'
current_dir=Dir.pwd
# tests dir is current
autoscale="#{current_dir}/../docker-swarm-autoscaler/auto-scale.sh"

describe 'auto-scale.sh' do
 create_standard_mocks

 context 'scaling docker swarm services' do
  it 'scales a service with lower than the minimum replicas' do
    set_standard_mock_outputs

    stdout, stderr, status = stubbed_env.execute("/bin/bash #{autoscale}", {'LOOP' => 'false'})
    expect(stdout).to include("Service hello_helloworld_too_low_cpu has an autoscale label.")
    expect(stdout).to include("Service hello_helloworld_too_low_cpu is below the minimum. Scaling to the minimum of 3")
    expect(status.exitstatus).to eq 0
  end

  it 'scales a service with low cpu down by 1 replica' do
    set_standard_mock_outputs

    stdout, stderr, status = stubbed_env.execute("/bin/bash #{autoscale}", {'LOOP' => 'false'})
    expect(stdout).to include("Service hello_helloworld_low_cpu has an autoscale label.")
    expect(stdout).to include("Scaling down the service hello_helloworld_low_cpu to 3")
    expect(status.exitstatus).to eq 0
  end
  it 'does not scale a service with low cpu when the minimum replicas is reached' do
    set_standard_mock_outputs

    stdout, stderr, status = stubbed_env.execute("/bin/bash #{autoscale}", {'LOOP' => 'false'})
    expect(stdout).to include("Service hello_helloworld_min_replicas_low_cpu has an autoscale label.")
    expect(stdout).to include("Service hello_helloworld_min_replicas_low_cpu has the minumum number of replicas.")
    expect(status.exitstatus).to eq 0
  end

  it 'scales a service with high cpu up by 1 replica' do
    set_standard_mock_outputs

    stdout, stderr, status = stubbed_env.execute("/bin/bash #{autoscale}", {'LOOP' => 'false'})
    expect(stdout).to include("Service hello_helloworld_high_cpu has an autoscale label.")
    expect(stdout).to include("Scaling up the service hello_helloworld_high_cpu to 4")
    expect(status.exitstatus).to eq 0
  end

  it 'does not scale a service with high cpu when the max replicas is reached' do
    set_standard_mock_outputs

    stdout, stderr, status = stubbed_env.execute("/bin/bash #{autoscale}", {'LOOP' => 'false'})
    expect(stdout).to include("Service hello_helloworld_high_cpu_full_replicas has an autoscale label.")
    expect(stdout).to include("Service hello_helloworld_high_cpu_full_replicas already has the maximum of 4 replicas")
    expect(status.exitstatus).to eq 0
  end

  it 'scales a service with more than the maximum number of replicas' do
    set_standard_mock_outputs

    stdout, stderr, status = stubbed_env.execute("/bin/bash #{autoscale}", {'LOOP' => 'false'})
    expect(stdout).to include("Service hello_helloworld_high_cpu_too_many_replicas has an autoscale label.")
    expect(stdout).to include("Service hello_helloworld_high_cpu_too_many_replicas is above the maximum. Scaling to the maximum of 4")
    expect(status.exitstatus).to eq 0
  end

  it 'does not scale a service without an autoscale label' do
    set_standard_mock_outputs

    stdout, stderr, status = stubbed_env.execute("/bin/bash #{autoscale}", {'LOOP' => 'false'})
    expect(stdout).to include("Service autoscale_docker-swarm-autoscaler does not have an autoscale label.")
    expect(status.exitstatus).to eq 0
  end
 end
end
