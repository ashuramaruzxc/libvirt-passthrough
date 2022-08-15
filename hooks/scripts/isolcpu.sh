#!/bin/bash

set -x

#Perfomance 
ulimit_original=$(ulimit -l)
ulimit_target=$((28*1024*1024))
ulimit -l $ulimit_target
sysctl vm.nr_hugepages=1024

until pid=$(pidof qemu-system-x86_64); do sleep 1; done

sleep 3

mkdir --verbose /sys/fs/cgroup/cpuset/system
mkdir --verbose /sys/fs/cgroup/cpuset/qemu

echo '0' > /sys/fs/cgroup/cpuset/system/cpuset.mems
echo '0,6' > /sys/fs/cgroup/cpuset/system/cpuset.cpus

echo '0' > /sys/fs/cgroup/cpuset/qemu/cpuset.mems
echo '0,6' > /sys/fs/cgroup/cpuset/qemu/cpuset.cpus

vcpus="3,9,4,10,5,11,2,8,1,7"
for (( i=0; i<=(($(echo $vcpus | sed 's/,/\n/g' | wc -l)-1)); i++ ))
do
    mkdir --verbose /sys/fs/cgroup/cpuset/qemu-cpu$(echo "$i")
    echo '0' > /sys/fs/cgroup/cpuset/qemu-cpu$(echo "$i")/cpuset.mems
    echo $(echo "$vcpus" | sed 's/,/\n/g' | sed "$(($i+1))q;d") > /sys/fs/cgroup/cpuset/qemu-cpu$(echo "$i")/cpuset.cpus
done

for (( i=0; i<=(($(echo $vcpus | sed 's/,/\n/g' | wc -l)-1)); i++ ))
    do
        pstree --numeric-sort --thread-names --ascii --show-pids $(pidof qemu-system-x86_64) | grep CPU.*$i.*KVM | awk --field-separator='(' '{print $2}' | awk --field-separator=')' '{print $1}' | xargs --max-args=1 --replace={} echo {} > /sys/fs/cgroup/cpuset/qemu-cpu$(echo "$i")/tasks
    done
pstree --numeric-sort --thread-names --ascii --show-pids $(pidof qemu-system-x86_64) | grep --invert-match 'CPU.*KVM' | awk --field-separator='(' '{print $2,$3}' | sed 's/)//g' | sed 's/-+-{qemu-system-x86}//g' | sed 's/\ /\n/g' | sed '/^$/d' | xargs --max-args=1 --replace={} echo {} > /sys/fs/cgroup/cpuset/qemu/tasks
cat /sys/fs/cgroup/cpuset/tasks | xargs --max-args=1 --replace={} echo {} > /sys/fs/cgroup/cpuset/system/tasks 2>/dev/null
