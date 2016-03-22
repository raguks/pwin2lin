#!/usr/bin/perl -w

# Dan Witt
# 5/28/2010
# Convert Windows PuTTY sessions to Linux
# Ragu only edited Dan Witt's script to work on KiTTY session registry

#How to use pwin2lin.pl
sub help {
print<<HELP
 Export the PuTTY registry settings from Windows:
 Start->Run->regedit
 HKEY_CURRENT_USER\\Software\\9bis.com\\
 Right click PuTTY and choose 'Export'. Save the registry file to your Linux machine and run this script from a shell (chmod 755 first):
 ./pwin2lin.pl

 Examples:
  Running the script alone:
    foo\@bar:~\$ ./pwin2lin.pl

  Specify files from the command line:
    foo\@bar:~\$ ./pwin2lin.pl myPuttySessions.reg /home/foo/.putty

HELP
}

# Includes
use Encode;
use File::Path;
use strict;

# Globals
my $winRegFile = "";
my $puttyPath = "";



if($#ARGV + 1) { # If any command line arguments are specified try to parse
  if($ARGV[0] eq "--help") {
    &help();
    exit;
  } elsif($ARGV[0] && $ARGV[1]) {
    $winRegFile = $ARGV[0];
    chomp $winRegFile;
    $puttyPath = $ARGV[1];
    chomp $puttyPath;
  } else {
    print "Usage:\n   ./pwin2lin.pl [Windows Reg File] [Path to save PuTTY sessions]\n   ./pwin2lin.pl --help\n";
    exit;
  }
} else { # Ask them where the registry file is and where they'd like to store the converted sessions.

  print "Specify the path and file to convert:\n";
  $winRegFile = <STDIN>;
  chomp $winRegFile;

  print "Specify the path to store the converted sessions:\n";
  $puttyPath = <STDIN>;
  chomp $puttyPath;
  $puttyPath = "./" if !$puttyPath;
}

# Open the file and convert it from UTF-16LE
open(FILE, "<:encoding(UTF-16LE):crlf", $winRegFile) or die $!;
my @lines = <FILE>;
close FILE;

mkpath "$puttyPath/sessions", 0740 unless -d "$puttyPath/sessions";

my $linesLen = scalar @lines;

# Parse the registry file, try to guess some settings
my $i = 0;
while($i < $linesLen) {
  chomp $lines[$i];
  if($lines[$i] =~
m/^\[HKEY_CURRENT_USER\\Software\\9bis.com\\KiTTY\\Sessions\\(.+)\]/)
{
    my $hostname = $1;
    $i++;
    next if $hostname =~ m/^Default.+Settings$/; # Use Linux Defaults
    #print "$hostname\n";
    open HOST, ">$puttyPath/sessions/$hostname" or die $!; # Write out the session
    while(1) {
      chomp $lines[$i];
      last if $lines[$i] eq "";
      $lines[$i] =~ s/\"//g;
      if($lines[$i] =~ m/dword:(.+)/) {
        my $dec = $1;
        if($dec eq "ffffffff") {
          $dec = -1;
        } else {
          $dec = hex($dec);
        }

        $lines[$i] =~ s/dword:.+/$dec/g;
      }
      $lines[$i] =~ s/^Font\=.+/FontName=server:fixed/g;
      $lines[$i] =~ s/^NoRemoteQTitle\=(.+)/RemoteQTitleAction\=$1/g;
      $lines[$i] =~ s/^SerialLine\=.+/SerialLine\=\/dev\/ttyS0/g;
      $lines[$i] =~ s/^FontVTMode\=.+/FontVTMode\=4/g;
      #print "$lines[$i]\n";
      print HOST "$lines[$i]\n";
      $i++;
    }
    close HOST;
  } elsif($lines[$i] =~
m/\[HKEY_CURRENT_USER\\Software\\9bis.com\\KiTTY\\SshHostKeys\]/) {
    $i++;
    open SSH, ">$puttyPath/sshhostkeys" or die $!;
    while($i < $linesLen) {
      chomp($lines[$i]);
      $lines[$i] =~ s/\"//g;
      print SSH "$lines[$i]\n";
      $i++;
    }
    close SSH;
  }
  $i++;
}
