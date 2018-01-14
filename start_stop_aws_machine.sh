#!/bin/bash
function usage(){
	echo "Usage: $0 -a <action> -i <instance-id>"
	echo "		-a action should be either start or stop and is mandatory"
	echo "		-i will indicate the instance id you are acting on, the parameter is mandatory"
	echo "		Optional: if you add the -install the script will install all of it's dependencies and exit"
	exit 1
}

##MAIN
#invoke usage if no argument are given
[[ $# -eq 0 ]] && usage

#check the machine has brew
if [ ! `command -v brew` ]; then
	if [[ $INSTALL ]]; then
		echo "missing Homebrew, installing it now"
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	else
		echo "'brew' is required but not found - to install it use the -install argument to install it"
		exit 1
	fi
fi

#check the machine has python pip
if [ ! `command -v pip` ]; then
	if [[ $INSTALL ]]; then
		echo "'pip' is required but not found - Will install it using home brew"
		brew install python
	else
		echo "'pip' is required but not found - use the -install argument to install it"
	fi
fi

#check the machine has awscli awscli
if [ ! `command -v aws` ]; then
	if [[ $INSTALL ]]; then
		echo "'aws' (aws cli) is required but not found - Will install it using pip"
		pip install awscli
	else
		echo "aws cli is required but not found - use the -install argument to install it"
	fi
fi

# read variables
while getopts "i:a:install" arg; do
  case $arg in
    i)
        export aws_instance_id="$OPTARG"
        ;;
    a)
        export action="$OPTARG"
        if [ $action != "start" ] || [ $action != "stop" ]; then
        	echo "instance action May only be start/stop.."
        	exit 1
        fi 
        ;;
    install)
        export INSTALL=true
        echo
        ;;
    h)
        usage
        ;;
  esac
done
shift $((OPTIND-1))

echo "Will now $action the machine with instance id: $aws_instance_id"

#if this was an installation run, then this machine need to configure credentials
[[ $INSTALL ]] && echo "Please run go to: https://docs.aws.amazon.com/cli/latest/reference/configure/ and run procedure"
[[ $INSTALL ]] && exit 0

aws ec2 ${action}-instances --instance-ids "$aws_instance_id" && echo "Will sleep for 20 second to allow the machi to start and allocate ip" && sleep 20 &&
aws ec2 describe-instances --instance-ids "$aws_instance_id" --output table
