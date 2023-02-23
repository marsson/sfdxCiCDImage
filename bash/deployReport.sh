#!/usr/bin/env bash
#@Author Marcelo Marsson & Adam Best
#sequence responsible for deploying and reporting

set -e
source functions.sh

SF_USERNAME=""
CMD=""
TYPE=""

#Validate Inputs
validate_deployReport "$@"

#echo "Sending deployment request..."
DEPLOY_RESULT="$(echo $CMD)"
#echo "DEPLOY_RESULT: $DEPLOY_RESULT"
# echo "Value = $DEPLOY_RESULT";
JOB_ID="$(echo "$DEPLOY_RESULT" | jq -r '.result.id')"
JOB_RESULT="$(echo "$DEPLOY_RESULT" | jq -r '.status')"

## Break if command fails
if [ "$JOB_RESULT" != 0 ]; then
  EXIT_MESSAGE=$(echo "$DEPLOY_RESULT" | jq -r '.message')
  echo $EXIT_MESSAGE
  exit 1
fi

echo " "
echo "*** Deploying ***"
echo "Job ID | $JOB_ID"

RESULT_DONE=false


while [ $RESULT_DONE != true ]; do
  {

    #Source or MDAPI commnand
    if [[ $TYPE == "source" ]]; then
      REPORT_CMD=$(sfdx force:source:deploy:report --json --loglevel ERROR -w 1 -u $SF_USERNAME -i $JOB_ID)
    fi
    if [[ $TYPE == "mdapi" ]]; then
      REPORT_CMD=$(sfdx force:mdapi:deploy:report --json --loglevel ERROR -w 1 -u $SF_USERNAME -i $JOB_ID)
    fi
    REPORT_RESULT="$(echo $REPORT_CMD)"

    # The system has been returning some errors timming out on the client connection. Because of that, we only want to
    # get the info once the result is successful. Hence the continue to the loop if we get a failure (Anything other than 0
    # on result means a failure.)

    RESULT="$(echo "$REPORT_RESULT" | jq -r '.status')"
    if [ "$RESULT" != 0 ]; then
      continue
    fi

    # Create all variables required for the calculations

    RESULT_DONE="$(echo "$REPORT_RESULT" | jq -r '.result.done')"
    RESULT_STATUS="$(echo "$REPORT_RESULT" | jq -r '.result.status')"
    RESULT_ERROR_CODE_STATUS="$(echo "$REPORT_RESULT" | jq -r '.result.errorStatusCode')"
    RESULT_ERROR_MESSAGE="$(echo "$REPORT_RESULT" | jq -r '.result.errorMessage')"
    NC_D="$(echo "$REPORT_RESULT" | jq -r '.result.numberComponentsDeployed')"
    NC_E="$(echo "$REPORT_RESULT" | jq -r '.result.numberComponentErrors')"
    NC_T="$(echo "$REPORT_RESULT" | jq -r '.result.numberComponentsTotal')"
    NT_T="$(echo "$REPORT_RESULT" | jq -r '.result.numberTestsTotal')"
    NT_C="$(echo "$REPORT_RESULT" | jq -r '.result.numberTestsCompleted')"
    NC_F="$(echo "$REPORT_RESULT" | jq -r '.result.numberTestErrors')"
    NC_CODE_COVERAGE_WARNING="$(echo "$REPORT_RESULT" | jq -r '.result.details.runTestResult.codeCoverageWarnings')"

  } ||
    { # catch
      echo "Job queuing..."
    }

chmod +x  $WORK_DIR/sfdx-pipelines/utils/deploy/progressbar.sh
"$WORK_DIR/sfdx-pipelines/utils/deploy/progressbar.sh" $NC_D $NC_T "Components" return
"$WORK_DIR/sfdx-pipelines/utils/deploy/progressbar.sh" $NT_C $NT_T "Test Methods"

done

"$WORK_DIR/sfdx-pipelines/utils/deploy/progressbar.sh" $NC_D $NC_T "Components" return
"$WORK_DIR/sfdx-pipelines/utils/deploy/progressbar.sh" $NT_C $NT_T "Test Methods"

if [ "$RESULT_STATUS" == "Failed" ]; then

  echo " "
  echo "=========================================================================================================="
  echo "Deployment Failed. Check below errors or login to salesforce sandbox for errors."
  echo "=========================================================================================================="
  echo " "

  if [ "$NC_E" == "0" ]; then
    echo "Component Errors: 0"
  else
    COMP_ERRORS="$(echo "$REPORT_RESULT" | jq -r '.result.details.componentFailures')"
    echo "=========================================================================================================="
    echo "Component Errors: $COMP_ERRORS"
    echo "=========================================================================================================="
  fi

  if [ "$NC_F" == "0" ]; then
    echo "Test Errors: 0"
  else
    TEST_ERRORS="$(echo "$REPORT_RESULT" | jq -r '.result.details.runTestResult.failures')"
    echo "=========================================================================================================="
    echo "Test Errors: $TEST_ERRORS"
    echo "=========================================================================================================="
  fi

  if [ -z "$NC_CODE_COVERAGE_WARNING" ]; then
    echo "Code Coverage Errors: 0"
  else
    echo "=========================================================================================================="
    echo "CODE COVERAGE ERRORS: $NC_CODE_COVERAGE_WARNING"
    echo "=========================================================================================================="
  fi

  if [ -z "$RESULT_ERROR_CODE_STATUS" ]; then
    echo " "
  else
    echo "=========================================================================================================="
    echo "ERROR MESSAGE: $RESULT_ERROR_MESSAGE"
    echo "=========================================================================================================="
  fi
  exit 1
fi

if [ "$RESULT_STATUS" == "Canceled" ]; then
  echo "=========================================================================================================="
  echo "ERROR MESSAGE: Deployment Was Cancelled on Salesforce Side"
  echo "=========================================================================================================="
  exit 1
fi

if [ "$RESULT_STATUS" == "Succeeded" ]; then
  echo "=========================================================================================================="
  echo "SUCCESS: Deployment Completed Awesomely"
  echo "=========================================================================================================="
  exit 0
fi
