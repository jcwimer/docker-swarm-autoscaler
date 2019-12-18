# docker-swarm-autoscaler unit tests

### Dependencies (packaged into docker with ./run-tests.sh)
#### [uses rspec-shell-expectations](https://github.com/matthijsgroen/rspec-shell-expectations)
------
1. Ruby 2.6.3
2. jq needs installed

### Gotchas
------
1. Do not use ${0} in scripts. Instead use ${BASH_SOURCE[0]}
2. Many times it is necessary to see the stdout and stderr in your test to see what you forgot to mock. For example, if your test is failing
you can do `expect(stdout).to eq ''` and rspec will fail and give you the stdout message. Same with stderr. This will help you mock the things
you might have overlooked.