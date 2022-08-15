#!/bin/bash
set -x
ulimit -l $ulimit_original
sysctl vm.nr_hugepages=0

cat /sys/fs/cgroup/cpuset/system/tasks | xargs --max-args=1 --replace={} echo {} >> /sys/fs/cgroup/cpuset/tasks 2>/dev/null
cat /sys/fs/cgroup/cpuset/qemu/tasks | xargs --max-args=1 --replace={} echo {} >> /sys/fs/cgroup/cpuset/tasks 2>/dev/null

for (( i=0; i<=(($(ls -l --directory /sys/fs/cgroup/cpuset/qemu-cpu* | wc -l)-1)); i++ ))
	do
		cat /sys/fs/cgroup/cpuset/qemu-cpu$(echo "$i")/tasks | xargs --max-args=1 --replace={} echo {} >> /sys/fs/cgroup/cpuset/tasks 2>/dev/null
	done
