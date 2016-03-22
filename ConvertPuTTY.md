# Introduction #

Help for running pwin2lin.pl to convert PuTTY sessions from Windows to Linux.

# Details #

Export the PuTTY registry settings from Windows:
Click on Start -> Run

Type in 'regedit' and hit Enter.

Navigate to:
> HKEY\_CURRENT\_USER\Software\SimonTatham\

Right click the 'PuTTY' folder and choose 'Export'. Save the registry file to your Linux machine and run pwin2lin from a shell (chmod 755 first):
> ./pwin2lin.pl

Examples:
> Running the script alone:
> > foo\@bar:~\$ ./pwin2lin.pl


> Specify files from the command line:
> > foo\@bar:~\$ ./pwin2lin.pl myPuttySessions.reg /home/foo/.putty