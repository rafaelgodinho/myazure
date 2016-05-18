#!/usr/bin/perl
use Switch;
$clushf="/etc/clustershell/groups.d/local.cfg";
$tmp=`awk '{print \$1}' /tmp/maprhosts`;chomp $tmp;
@tmp=split(/\n/,$tmp);

$nnodes=$#tmp+1;

if ($tmp[0]=~/^(.*)node(\d+)$/){
$nbase=$1 . "node";
}

system("yum -y install mysql-server ansible");
system("chkconfig mysqld on; service mysqld start");
system("ysqladmin -u root password "$ARGV[0]");
system("sed -i \"s/^all:.*/all:$nbase\[0-$#tmp]/g\" $clushf");

switch($nnodes){
case 1 {@zk=qw(0);@cldb=qw(0);@rm=qw(0);@hs=qw(0);@web=qw(0);}
case 3 {@zk=qw(0 1 2);@cldb=qw(0);@rm=qw(0 1);@hs=qw(2);@web=qw(0);}
case 5 {@zk=qw(0 1 2);@cldb=qw(0 1);@rm=qw(4 5);@hs=qw(4);@web=qw(0);}
else { }
}

$zk="zk:";
foreach $h (@zk){
$zk= $zk . $nbase . $h . ",";
}
chop $zk;

$cldb="cldb:";
foreach $h (@cldb){
$cldb= $cldb . $nbase . $h . ",";
}
chop $cldb;

$rm="rm:";
foreach $h (@rm){
$rm= $rm . $nbase . $h . ",";
}
chop $rm;

$hs="hs:";
foreach $h (@hs){
$hs= $hs . $nbase . $h . ",";
}
chop $hs;

$web="web:";
foreach $h (@web){
$web= $web . $nbase . $h . ",";
}
chop $web;

open(FILE,">>$clushf");
print FILE "$cldb\n$zk\n$rm\n$hs\n$web\n";
close(FILE);

$inst_script="
clush -g zk yum install mapr-zookeeper -y
clush -a yum install mapr-fileserver mapr-nfs mapr-nodemanager -y
clush -g cldb yum install mapr-cldb -y
clush -g rm yum install mapr-resourcemanager -y
clush -g hs yum install mapr-historyserver -y
clush -g web yum install mapr-webserver -y

clush -a /opt/mapr/server/configure.sh -C `nodeset -S, -e \@cldb` -Z `nodeset -S, -e \@zk` -N mapr -RM `nodeset -S, -e \@rm` -HS `nodeset -S, -e \@hs` -no-autostart

clush -a /opt/mapr/server/disksetup -F /tmp/MapR.disks

clush -a \"sed -i 's/#export JAVA_HOME=/export JAVA_HOME=\\/usr\\/java\\/latest/g' /opt/mapr/conf/env.sh\"

clush -a mkdir -p /mapr
echo \"localhost:/mapr  /mapr  hard,nolock\" > /opt/mapr/conf/mapr_fstab
clush -ac /opt/mapr/conf/mapr_fstab --dest /opt/mapr/conf/mapr_fstab

clush -a /etc/init.d/mapr-zookeeper start
clush -a /etc/init.d/mapr-warden start
";

open(INST,">/tmp/mapr_install.sh");
print INST $inst_script;
close(INST);

system("sh /tmp/mapr_install.sh");

#wait for the cluster to be ready
$checkfs=$checkmcs=$mtime=0;
do{

$fs=`hadoop fs -ls /tmp`; chomp $fs;
if ($fs eq ""){$checkfs=1}

$mcs=`lsof -i :8443`; chomp $mcs;
if ($mcs ne ""){$checkmcs=1}

print "Waiting for cluster to be ready...\n";
sleep 2;
$mtime=$mtime+2;

if ($mtime >=100){print "Cluster failed to install\n";exit 1;}

}until($checkfs==1 & $checkmcs==1);
print "Cluster is ready...\n";
