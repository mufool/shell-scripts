#!/bin/bash

use_host=true
is_namenode=true
is_master=true
base="/opt/hadoop"
hadoop=$base"/hadoop-2.6.5"
spark=$base"/spark-2.1.0"
zk=$base"/zookeeper-3.4.9"
kafka=$base"/kafka_2.12"

sparkmaster="192.168.206.184"

hostname=`hostname`
if [ "$use_host" == "false" ]; then
	echo "user ip config"
	hostname=`grep ${hostname} "/etc/hosts" | awk '{print $1}'`
fi

# common

function log_info()
{
	echo info: $1
}

function log_error()
{
	echo error: $1
}

#spark
function check_spark_master()
{
	echo "-------------------check spark master---------------------------"
	if [ $is_namenode != "true" ];then
		log_error "not spark master or hostname not found"
		return
	fi

	masterid=`ps -ef | grep Master | grep spark | awk '{print $2}'`
	log_info "spark master pid: "$masterid

	if [ "$masterid" =  "" ]; then
		log_info "spark master is restart"
		${spark}"/sbin/stop-master.sh"
		${spark}"/sbin/start-master.sh"
	else
		log_info "spark master is alive"
	fi
}

function check_spark_slave()
{
	echo "-------------------check spark slave---------------------------"
	if [ $is_namenode == "true" ];then
		log_error "not spark slave or hostname not found"
		return
	fi

	slaveid=`ps -ef | grep Worker | grep spark | grep 7077 | awk '{print $2}'`
	log_info "spark slave pid: "$slaveid

	if [ "$slaveid" =  "" ]; then
		log_info "spark worker is restart"
		${spark}"/sbin/stop-slave.sh"
		${spark}"/sbin/start-slave.sh" spark://$sparkmaster:7077
	else
		log_info "spark worker is alive"
	fi
}

if [ -f $spark"/conf/slaves" ]; then
	if grep -Fxq $hostname $spark"/conf/slaves"; then
		check_spark_slave
	else
		check_spark_master
	fi
else
	log_info "no spark found"
fi

#hadoop

function check_hadoop_master()
{
	echo "-------------------check hadoop namenode---------------------------"
	if [ $is_namenode != "true" ];then
		log_error "not hadoop namenode or hostname not found"
		return
	fi

	namenodeid=`ps -ef | grep namenode.NameNode | grep -v grep | awk '{print $2}'`
	log_info "hadoop namenode pid: "$namenodeid

	if [ "$namenodeid" =  "" ]; then
		log_info "hadoop namenode is restart"
		"${hadoop}/sbin/hadoop-daemon.sh" stop namenode
		"${hadoop}/sbin/hadoop-daemon.sh" start namenode
	else
		log_info "hadoop namenode is alive"
	fi
}

function check_hadoop_slave()
{
	echo "-------------------check hadoop datanode---------------------------"
	if [ $is_namenode == "true" ];then
		log_error "not hadoop datanode or hostname not found"
		return
	fi

	datanode=`ps -ef | grep datanode.DataNode | grep -v grep | awk '{print $2}'`
	log_info "hadoop datanode pid: "$datanode
	log_info "hadoop datanode is alive"
}

if [ -f $hadoop"/etc/hadoop/slaves" ]; then
	if grep -Fxq $hostname $hadoop"/etc/hadoop/slaves"; then
		check_hadoop_slave
	else
		check_hadoop_master
	fi
else
	log_info "no hadoop found"
fi

#zk

function check_zk()
{
	zkid=`ps -ef | grep QuorumPeerMain | grep -v grep  | awk '{print $2}'`
	log_info "zk pid: "$zkid

	if [ "$zkid" =  "" ]; then
		log_info "Zookeeper is restart"
		${zk}"/bin/zkServer.sh" stop
		${zk}"/bin/zkServer.sh" start
		${zk}"/bin/zkServer.sh" status
	else
		log_info "zookeeper is alive"
	fi
}

echo "-------------------check zookeeper---------------------------"

if [ -f $zk"/conf/zoo.cfg" ]; then
	if grep -q $hostname $zk"/conf/zoo.cfg"; then
		check_zk
	else
		log_info "no zk found"
	fi
else
	log_info "no zk found"
fi

#kafka
function check_kafka()
{
	echo "-------------------check kafka---------------------------"

	kafkaid=`ps -ef | grep kafka.Kafka | grep -v grep  | awk '{print $2}'`
	log_info "kafka pid: "$kafkaid

	if [ "$kafkaid" =  "" ]; then
		log_info "kafka is restart"
		${kafka}"/bin/kafka-server-stop.sh"
		${kafka}"/bin/kafka-server-start.sh" ${kafka}"/config/server.properties" &
	else
		log_info "kafka is alive"
	fi
}

if [ -f $kafka"/config/server.properties" ]; then
	if grep -q $hostname":2181" $kafka"/config/server.properties"; then
		check_kafka
	else
		log_info "no kafka found"
	fi
else
	log_info "no kafka found"
fi
