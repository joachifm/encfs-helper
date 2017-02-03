#! /usr/bin/env perl

use strict;
use warnings;
use autodie;
use v5.16;

my $keyfile = $ENV{'PWD'} . "/crypt_key.gpg";
my $volume = $ENV{'PWD'} . "/crypt";

exit(main(@ARGV));

sub main {
  umask 077;
  init();
  return 0;
}

sub init {
  if (! -f $keyfile) {
    system("head -c512 /dev/urandom | gpg --batch -o $keyfile -e");
  }

  if (! -f "$volume/.encfs6.xml") {
    my $tmpmnt = `mktemp -d`;
    system("yes | encfs --extpass='gpg --batch -d $keyfile' --standard $volume $tmpmnt");
    system("fusermount -u $tmpmnt");
    system("rmdir $tmpmnt");

    my $confbak = $ENV{'PWD'} . "/crypt_encfs6.xml.bak.gpg";
    system("gpg -o $confbak -e $volume/.encfs6.xml");

    say STDERR "created new encfs volume at $volume";
    say STDERR "created encrypted backup of the encfs config at $confbak";
    say STDERR "please make an offline copy of $confbak and $keyfile";
  }
}
