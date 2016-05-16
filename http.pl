#!/usr/bin/perl
$myname=`hostname`; chomp $myname;

$success=1;

if ($hname eq $ARGV[0]){
 #this is the first node
 system("mkdir -p /root/.ssh");
 system("cp ~mapradmin/.ssh/authorized_keys /root/.ssh");
 system("cp ~mapradmin/.ssh/id_rsa /root/.ssh");
 system("cp ~mapradmin/.ssh/authorized_keys /var/www/html/key");

}else{

while ($success != 0){
  print "failed\n";
  sleep 2;
  `wget http://jsunmoonode0/key -O authorized_keys`;
  $success=$?;
}

}
