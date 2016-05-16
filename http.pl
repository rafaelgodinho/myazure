#!/usr/bin/perl
$myname=`hostname`; chomp $myname;

$success=1;

if ($myname eq $ARGV[0]){
 print "this is the first node\n";
 system("yum -y install httpd");
 system("service httpd restart");
 system("mkdir -p /root/.ssh");
 system("cp ~mapradmin/.ssh/authorized_keys /root/.ssh");
 system("rm -f /root/.ssh/id_rsa.pub");
 system("cp ~mapradmin/.ssh/id_rsa /root/.ssh");
 system("cp ~mapradmin/.ssh/authorized_keys /var/www/html/key");
 system("chmod 755 /var/www/html/key");

}else{

while ($success != 0){
  print "failed\n";
  sleep 2;
  `wget http://$ARGV[0]/key -O /tmp/authorized_keys`;
  $success=$?;
}
  print "Key copying succeeded\n";
  system("mkdir -p /root/.ssh");
  system("cp /tmp/authorized_keys /root/.ssh/authorized_keys");
}
