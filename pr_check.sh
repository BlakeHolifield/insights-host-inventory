#!/bin/bash

# --------------------------------------------
# Pre-commit checks
# --------------------------------------------
APP_NAME="host-inventory"  # name of app-sre "application" folder this component lives in
IMAGE="quay.io/cloudservices/insights-inventory"
BG_PID=1010101
RANDOM_PORT=65000
export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

cat /etc/redhat-release

python3.6 -m venv venv
source venv/bin/activate
pip install pipenv
pipenv install --dev

if ! (pre-commit run --all-files); then
  echo "pre-commit ecountered an issue"
  exit 1
fi

# --------------------------------------------
# Options that must be configured by app owner
# --------------------------------------------
COMPONENT_NAME="host-inventory"  # name of app-sre "resourceTemplate" in deploy.yaml for this component

IQE_PLUGINS="host_inventory"
IQE_MARKER_EXPRESSION="smoke"
IQE_FILTER_EXPRESSION=""

# ---------------------------
# We'll take it from here ...
# ---------------------------

# Get bonfire helper scripts
CICD_URL=https://raw.githubusercontent.com/RedHatInsights/bonfire/master/cicd
curl -s $CICD_URL/bootstrap.sh -o bootstrap.sh
source bootstrap.sh  # checks out bonfire and changes to "cicd" dir...

# build the PR commit image
source build.sh

# Run the django unit tests
source ${WORKSPACE}/unit_test.sh

# Smoke test the App (iqe tests coming soon)
source deploy_ephemeral_env.sh
# source smoke_test.sh

mkdir -p $WORKSPACE/artifacts
cat << EOF > ${WORKSPACE}/artifacts/junit-dummy.xml
<testsuite tests="1">
    <testcase classname="dummy" name="dummytest"/>
</testsuite>
EOF
