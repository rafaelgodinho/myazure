#!/usr/bin/expect
set timeout -1
set arg1 [lindex $argv 0]
set arg2 [lindex $argv 1]
set host $arg1
set passwd $arg2
set user "mapradmin"

spawn $env(SHELL)
match_max 100000

send "sudo cp -f ~mapr/.ssh/id_launch /root/.ssh/id_rsa\r"
expect "#"
sleep .2

send -- "sudo chmod 600 /root/.ssh/id_rsa\r"
expect "#"
sleep .2

send -- "ssh $user@$host\r"
expect "Password: "

send -- "$passwd\r"
expect "mapradmin"
sleep .2

send -- "sudo mkdir -p /root/.ssh\r"
expect "mapradmin"
sleep .2

send -- "Y4uask!!\r"
expect "mapradmin"
sleep .2

send -- "sudo cp ~mapr/.ssh/id_launch.pub /root/.ssh/authorized_keys\r"
expect "mapradmin"
sleep .2

send -- "sudo sed -i 's/^#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config\r"
expect "mapradmin"
sleep .2

send -- "sudo service sshd restart\r"
expect "mapradmin"
sleep .2

send -- "exit\r"
expect "#"
