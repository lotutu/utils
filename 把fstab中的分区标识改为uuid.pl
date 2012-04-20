#!/usr/bin/perl
use warnings;
use strict;
# 这个程序用来把/etc/fstab 文件的挂载项由 /dev/sd* 这样的标志改成uuid的标志

# 要求超级用户的权限
print "程序运行需要超级用户的权限,尝试以root用户或者sudo方式运行\n" 
	and exit 1 if $< !=0;

chdir "/dev/disk/by-uuid";
my %devices;
my @uuids = glob("*");
foreach my $uuid(@uuids){
    my $dev_name = readlink($uuid); # 关联数组的键为sda10这样的词
    $dev_name =~ m/([^\/]*)$/ and $dev_name = $1;
    $devices{$dev_name}= $uuid;
}

#  开始处理 /etc/fstab文件, 读取文件内容修改dev/* 至 uuid后重新写入
my $config_file = "/etc/fstab";
open (my $RD, "<$config_file") or die "无法打开$config_file进行读取";
my @contents = <$RD>;

my @new_contents;
foreach my $line (@contents){
	if ($line =~ m/^\s*\/dev\/(sd[^\s]+)(\s+.*)$/) {
		# $1 存储 /dev/sda1 这样的东西, $2 存储余下的东西
		defined $devices{$1} and  $line = "UUID=". $devices{$1} . $2
			or warn "/dev/$1 可能不是一个有效的设备";
	}
	push @new_contents,$line;
}
close $RD;

# 写入文件
open (my $WD, ">$config_file") or die "无法写入$config_file! 程序退出";
print $WD @new_contents;
print $WD "\n";
close $WD;

# vim: set filetype=perl :
