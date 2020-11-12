#!/bin/bash


PACKAGE_NAME=kafka-collector-plugin
PACKAGE_PATH=$(dirname "$(cd `dirname $0`; pwd)")
LOG_DIRECTORY=$PACKAGE_PATH/log
LOG_FILE=$LOG_DIRECTORY/$PACKAGE_NAME.log


if ! type getopt >/dev/null 2>&1 ; then
  message="command \"getopt\" is not found"
  echo "[ERROR] Message: $message" >& 2
  echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR] Message: $message" > $LOG_FILE
  exit 1
fi

getopt_cmd=`getopt -o h -a -l help:,kafka-server:,exporter-host:,exporter-port:,exporter-uri: -n "start_script.sh" -- "$@"`
if [ $? -ne 0 ] ; then
    exit 1
fi
eval set -- "$getopt_cmd"


kafka_server="127.0.0.1:9092"
exporter_host="0.0.0.0"
exporter_port=9308
exporter_uri="/metrics"

print_help() {
    echo "Usage:"
    echo "    start_script.sh [options]"
    echo "    start_script.sh --kafka-server 127.0.0.1:9092 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                 show help"
    echo "      --kafka-server         addresses (host:port) of kafka server (\"127.0.0.1:9092\" by default)"
    echo "      --exporter-host        the listen address of exporter (\"0.0.0.0\" by default)"
    echo "      --exporter-port        the listen port of exporter (9104 by default)"
    echo "      --exporter-uri         the uri to expose metrics (\"/metrics\" by defualt)"
}

while true
do
    case "$1" in
        -h | --help)
            print_help
            shift 1
            exit 0
            ;;
        --kafka-server)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    kafka_server="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --exporter-host)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    exporter_host="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --exporter-port)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    exporter_port="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --exporter-uri)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    exporter_uri="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --)
            shift
            break
            ;;
        *)
            message="argument \"$1\" is invalid"
            echo "[ERROR] Message: $message" >& 2
            echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR] Message: $message" > $LOG_FILE
            print_help
            exit 1
            ;;
    esac
done

mkdir -p $LOG_DIRECTORY

message="start exporter"
echo "[INFO] Message: $message"
echo "$(date "+%Y-%m-%d %H:%M:%S") [INFO] Message: $message" >> $LOG_FILE

cd $PACKAGE_PATH
chmod +x src/kafka_exporter
./src/kafka_exporter --kafka.server=$kafka_server --web.listen-address=$exporter_host:$exporter_port --web.telemetry-path=$exporter_uri  >/dev/null 2>$LOG_FILE &
# 获得执行的pid
echo $!