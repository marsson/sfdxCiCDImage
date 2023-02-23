#!/bin/bash
#@author Marcelo Marsson
#@Description Functions utilized by other classes.
#
generateLogo() {
  echo ' __       __   ______   _______    ______    ______  '
  echo '|  \     /  \ /      \ |       \  /      \  /      \ '
  echo '| $$\   /  $$|  $$$$$$\| $$$$$$$\|  $$$$$$\|  $$$$$$\'
  echo '| $$$\ /  $$$| $$__| $$| $$__| $$| $$___\$$| $$___\$$'
  echo '| $$$$\  $$$$| $$    $$| $$    $$ \$$    \  \$$    \ '
  echo '| $$\$$ $$ $$| $$$$$$$$| $$$$$$$\ _\$$$$$$\ _\$$$$$$\'
  echo '| $$ \$$$| $$| $$  | $$| $$  | $$|  \__| $$|  \__| $$'
  echo '| $$  \$ | $$| $$  | $$| $$  | $$ \$$    $$ \$$    $$'
  echo ' \$$      \$$ \$$   \$$ \$$   \$$  \$$$$$$   \$$$$$$ '
  echo ''
  echo '  ______   __    __                                  '
  echo ' /      \ |  \  |  \                                 '
  echo '|  $$$$$$\| $$\ | $$                                 '
  echo '| $$  | $$| $$$\| $$                                 '
  echo '| $$  | $$| $$$$\ $$                                 '
  echo '| $$  | $$| $$\$$ $$                                 '
  echo '| $$__/ $$| $$ \$$$$                                 '
  echo ' \$$    $$| $$  \$$$                                 '
  echo '  \$$$$$$  \$$   \$$                                 '
  echo ''
  echo '  ______   ______        __   ______   _______       '
  echo ' /      \ |      \      /  \ /      \ |       \      '
  echo '|  $$$$$$\ \$$$$$$     /  $$|  $$$$$$\| $$$$$$$\     '
  echo '| $$   \$$  | $$      /  $$ | $$   \$$| $$  | $$     '
  echo '| $$        | $$     /  $$  | $$      | $$  | $$     '
  echo '| $$   __   | $$    /  $$   | $$   __ | $$  | $$     '
  echo '| $$__/  \ _| $$_  /  $$    | $$__/  \| $$__/ $$     '
  echo ' \$$    $$|   $$ \|  $$      \$$    $$| $$    $$     '
  echo '  \$$$$$$  \$$$$$$ \$$        \$$$$$$  \$$$$$$$     '
  echo ' '
  echo ' '
  return 0
}

function validate_build() {
  # Initialize variables
  DEPLOYMENT_TYPE=""
  TARGET_BRANCH=""
  SFDX_PATH=""

  # Parse command line options
  while getopts ":t:b:p:h" opt; do
    case ${opt} in
      t)
        DEPLOYMENT_TYPE="$OPTARG"
        if [ "$DEPLOYMENT_TYPE" != "full" ] && [ "$DEPLOYMENT_TYPE" != "delta" ]; then
          echo "Error: Only 'full' or 'delta' deployment methods are supported at the moment. Please check your settings."
          validate_build -h
          return 1
        fi
        ;;
      b)
        TARGET_BRANCH="$OPTARG"
        ;;
      p)
        SFDX_PATH="$OPTARG"
        ;;
      h)
        echo "Usage: $0 -t <TYPE> -p <PATH> [-b <BRANCH>]"
        echo " -t TYPE: the deployment type for the process. Either 'full' for full deployment or 'delta' for delta deployment are supported. The -t argument is mandatory. If it is not set, an error will be returned."
        echo " -p PATH: the path where the deployment will be made. This argument is mandatory."
        echo " -b BRANCH: the target branch for delta deployment. This argument is mandatory if the -t flag is set to 'delta'."
        return 1
        ;;
      \?)
        echo "Error: Invalid option: -$OPTARG" >&2
        validate_build -h
        return 1
        ;;
      :)
        echo "Error: Option -$OPTARG requires an argument." >&2
        validate_build -h
        return 1
        ;;
    esac
  done

  # Check if mandatory flags are set
  if [ -z "$DEPLOYMENT_TYPE" ]; then
    echo "Error: -t flag is mandatory." >&2
    return 1
  fi

  if [ -z "$SFDX_PATH" ]; then
    echo "Error: -p flag is mandatory." >&2
    return 1
  fi

  if [ "$DEPLOYMENT_TYPE" == "delta" ] && [ -z "$TARGET_BRANCH" ]; then
    echo "Error: -b flag is mandatory when -t flag is set to 'delta'." >&2
    return 1
  fi

  # The script can now continue with the deployment process
  echo "Deployment type: $DEPLOYMENT_TYPE"
  echo "SFDX path: $SFDX_PATH"
  if [ ! -z "$TARGET_BRANCH" ]; then
    echo "Target branch: $TARGET_BRANCH"
  fi
  return 0
}

function validate_deployReport() {
  # Initialize variables
  SF_USERNAME=""
  CMD=""
  TYPE=""

  # Parse command line options
  while getopts ":u:c:t:h" opt; do
    case ${opt} in
      u)
        DEPLOYMENT_TYPE="$OPTARG"
        SF_USERNAME="$OPT_ARGS"
        ;;
      c)
        CMD="$OPTARG"
        ;;
      t)
       TYPE="$OPTARG"
        ;;
      h)
        echo "Usage: $0 -u <USERNAME> -c <COMMAND> [-t <TYPE>]"
        echo " -u USERNAME: the username for sfdx The -u argument is mandatory. If it is not set, an error will be returned."
        echo " -c COMMAND: the sfdx command to be executed. This argument is mandatory."
        echo " -t TYPE: Type should be either MDAPI or Source."
        return 1
        ;;
      \?)
        echo "Error: Invalid option: -$OPTARG" >&2
        validate_build -h
        return 1
        ;;
      :)
        echo "Error: Option -$OPTARG requires an argument." >&2
        validate_build -h
        return 1
        ;;
    esac
  done

  # Check if mandatory flags are set
  if [ -z "$SF_USERNAME" ]; then
    echo "Error: -u flag is mandatory." >&2
    return 1
  fi

  if [ -z "$TYPE" ]; then
    echo "Error: -t flag is mandatory." >&2
    return 1
  fi

  if [ -z "$TYPE" ]; then
    echo "Error: -t flag is mandatory." >&2
    return 1
  fi
if [ -z "$CMD" ]; then
    echo "Error: -c flag is mandatory." >&2
    return 1
  fi

  return 0
}

