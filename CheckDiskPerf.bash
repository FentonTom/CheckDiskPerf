#!/bin/bash
## CheckDiskPerf.bash
## A script to check the perfomance of a drive
## Tom Fenton
## Ver 1 Wed 03 Feb 2021 06:28:17 PM UTC
## Stuff lect to do
## clean up old outputfiles
## Colorize output
## get dd command out put in the right place
## get better fio tests
## Shell subroutine to echo to screen and a log file
echolog()
(
    echo "$@"
    echo "$@" >> $OutFile
)
##
today=`date '+%Y_%m_%d__%H_%M_%S'`
OutFile="./$today.SDBTestRun.out"
echo $Outfile
echolog $today
## Vars
FioRunTime=
echolog "MSG FioRunTime is $FioRunTime"
FioNumJobs=2
echolog "MSG FioNumJobs is $FioNumJobs"
##


echolog "MSG General Disk Info"
 lshw -C disk &>> $OutFile
 fdisk -l  &>> $OutFile ## (this showed the 50GiB drive as /dev/sdb)
 hdparm -I /dev/sdb &>> $OutFile ## (this showed a VMware virtual SATA hard drive)

echolog "MSG General Perfoamance Info - hdparm"
## get basic performance data from the drive:
 hdparm -Tt /dev/sdb &>> $OutFile ## (this showed cache and buffer reads)
echolog "MSG General Perfoamance Info - DD"
 dd if=/dev/zero of=/dev/sdb bs=4k count=5M &>> $OutFile

echolog "MSG Perfoamance Info - fio 4k write rand test" >> $OutFile
##  run a random write 4k test:
 fio --filename=/dev/sdb --ioengine=libaio --rw=randwrite --bs=4k --numjobs=1 --size=4g --iodepth=32 --runtime=$FioRunTime --time_based --end_fsync=1 --name=4krandwrite  >> $OutFile

echolog "MSG Perfoamance Info - fio 4k read seq test"
##  run a random write 4k test:
 fio --filename=/dev/sdb --ioengine=libaio --rw=read --bs=4k --numjobs=1 --size=4g --iodepth=32 --runtime=$FioRunTime --time_based --end_fsync=1 --name=4kSeqWrite  >> $OutFile

echolog "MSG Perfoamance Info - fio 4k 80/20  test"
 ## run a random 80% read, 20% write, 4k write mix:
 fio --filename=/dev/sdb --ioengine=libaio --rw=randrw --rwmixread=80 --bs=4k --numjobs=1 --size=4g --iodepth=32 --runtime=$FioRunTime --time_based --end_fsync=1 --name=4krandRW  >> $OutFile

echolog "MSG Perfoamance Info - fio 1024k write test"
 fio --filename=/dev/sdb --ioengine=libaio --rw=randwrite --bs=1024k --numjobs=1 --size=4g --iodepth=32 --runtime=$FioRunTime --time_based --end_fsync=1 --name=1024krandwrite  >> $OutFile

echolog "MSG Perfoamance Info - fio 1024k read seq test"
##  run a random write 4k test:
 fio --filename=/dev/sdb --ioengine=libaio --rw=read --bs=1024k --numjobs=1 --size=4g --iodepth=32 --runtime=$FioRunTime --time_based --end_fsync=1 --name=1024kSeqWrite >>$Outfile

echolog "MSG Perfoamance Info - fio 1024k 80/20  test"
 ## run a random 80% read, 20% write, 4k write mix:
 fio --filename=/dev/sdb --ioengine=libaio --rw=randrw --rwmixread=80 --bs=1024k --numjobs=1 --size=4g --iodepth=32 --runtime=$FioRunTime --time_based --end_fsync=1 --name=1024krandRW  >> $OutFile

EndTime=`date '+%Y_%m_%d__%H_%M_%S'`;
echolog "Job Finished at $EndTime"

rm "./last.SDBTestRun.out"
cp $OutFile  "./last.SDBTestRun.out"

grep -A 3 'DD' $OutFile
grep 'MSG\|iops\|read\|write' $OutFile
