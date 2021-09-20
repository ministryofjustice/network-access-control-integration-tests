#!/bin/bash
set -eo pipefail

./test/scripts/test_eap.sh
./test/scripts/test_policy_engine.sh