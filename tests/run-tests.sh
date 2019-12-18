#!/usr/bin/env bash
set -ex

function main {
  build-image
  run-ruby-tests
}

function cd-to-top-of-repo {
  cd "$(git rev-parse --show-toplevel)"
}

function build-image {
  cd-to-top-of-repo
  docker build -t docker-swarm-autoscaler-tests ./tests
}

function run-ruby-tests {
  cd-to-top-of-repo
  echo 'INFO: Running rspec unit tests...'
  local -r container_id=$(
    docker create --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      docker-swarm-autoscaler-tests \
      bash -c "cd /root/tests && \
      bundle exec rake spec"
  )

  docker cp . "${container_id}:/root/"

  trap "docker rm ${container_id}" SIGHUP
  docker start --attach --interactive "${container_id}"
}

[[ "${0}" == "${BASH_SOURCE[0]}" ]] && main "${@}"
