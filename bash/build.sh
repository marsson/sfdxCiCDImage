#!/bin/bash
      set -euo pipefail;
      source functions.sh
# Set default values for the deployment type
    DEPLOYMENT_TYPE=""
    TARGET_BRANCH=""
    SFDX_PATH=""
# run validation for the build
      validate_build "$@"
# run the cool as logo
      generateLogo
      sleep .5
      echo "INFO: Create deployment directory";
      DEPLOY_PATH=$SFDX_PATH/deploy

      rm -rf $DEPLOY_PATH;
      mkdir -p $DEPLOY_PATH;
      chmod +r $DEPLOY_PATH;

# Navigate to SFDX directory
      cd $SFDX_PATH
      # echo "Git Branch: " && git branch

      if [ "$DEPLOYMENT_TYPE" == "diff" ];then
        echo "Choose Packgae Deployment Type: Diff from target branch: $TARGET_BRANCH"

        TO_COMMMIT_ID="HEAD"
        FROM_COMMMIT_ID="remotes/origin/$TARGET_BRANCH"

      else
        ## catches to Diff from main
        TO_COMMMIT_ID="HEAD"
        FROM_COMMMIT_ID="remotes/origin/main"
      fi



        sfdx sgd:source:delta \
        -o $DEPLOY_PATH \
        --to $TO_COMMMIT_ID \
        --from $FROM_COMMMIT_ID \
        --generate-delta


# If full deployment copy all the items from the source
      if [ "$DEPLOYMENT_TYPE" == "Full Deployment" ];then
          echo "FIXING PACKAGE FOR FULL DEPLOYMENT"
          rm -rf "$DEPLOY_PATH"/src
          cp -R "$SFDX_PATH/src" "$DEPLOY_PATH"
      fi


      echo "####################################################################################";
      echo "INFO: START: Check ignored files";
      sfdx force:source:ignored:list --sourcepath=$DEPLOY_PATH
      echo "INFO: END: Check ignored files";
      echo "####################################################################################";
      echo " "
      echo " "


      INCLUDES_PATH="$SFDX_PATH/.includefiles"
      if [ -e "${INCLUDES_PATH}" ]; then

        echo "####################################################################################";
        echo "INFO: START: Check included files found in $SFDX_PATH/.includefiles";
        cat $SFDX_PATH/.includefiles
        echo "INFO: END: Check included files found in $SFDX_PATH/.includefiles";
        echo "####################################################################################";
        echo " "
        echo " "

      fi

      echo "####################################################################################";
      echo "INFO: START: List of files in main deployment directory ('$DEPLOY_PATH'):";
      cd $DEPLOY_PATH && find .
      echo "INFO: END: List of files in main deployment directory ('$DEPLOY_PATH'):";
      echo "####################################################################################";
      echo " "
