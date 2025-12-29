#!/usr/bin/perl
use strict;
use warnings;

# Colors
my $RED    = "\033[0;31m";
my $YELLOW = "\033[0;33m";
my $GREEN  = "\033[0;32m";
my $NC     = "\033[0m";

# Banner
print $RED;
print "███╗   ██╗███╗   ███╗ █████╗ ██████╗ \n";
print "████╗  ██║████╗ ████║██╔══██╗██╔══██╗\n";
print "██╔██╗ ██║██╔████╔██║███████║██████╔╝\n";
print "██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝ \n";
print "██║ ╚████║██║ ╚═╝ ██║██║  ██║██║     \n";
print "╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     \n";
print "${YELLOW}        Made by Light Bringer${NC}\n\n";

# Arguments
my ($TARGET, $TYPE) = @ARGV;
my $OUTPUT = "nmap-$TARGET";

sub usage {
    print "\n${RED}Usage: $0 <TARGET-IP> <TYPE>${NC}\n";
    print "${YELLOW}Scan Types:\n";
    print "\tQuick   : Fast TCP scan\n";
    print "\tBasic   : Quick + version & script scan\n";
    print "\tUDP     : UDP scan\n";
    print "\tFull    : Full port scan\n";
    print "\tVulns   : Vulnerability scan\n";
    print "\tAll     : Run all scans\n";
    print "${NC}\n";
    exit 1;
}

sub check_args {
    usage() unless ($TARGET && $TYPE);
}

sub quick_scan {
    print "${GREEN}[+] Running Quick Scan${NC}\n";
    system("nmap -T5 -F $TARGET -oN ${OUTPUT}-quick.txt");
}

sub basic_scan {
    print "${GREEN}[+] Running Basic Scan${NC}\n";
    system("nmap -T4 -F $TARGET -oG ${OUTPUT}-ports.gnmap");

    open my $fh, "<", "${OUTPUT}-ports.gnmap" or return;
    my @ports;

    while (<$fh>) {
        if (/(\d+)\/open\//) {
            push @ports, $1;
        }
    }
    close $fh;

    if (@ports) {
        my $port_list = join(",", @ports);
        system("nmap -sC -sV -p $port_list $TARGET -oN ${OUTPUT}-basic.txt");
    }
}

sub udp_scan {
    print "${GREEN}[+] Running UDP Scan${NC}\n";
    system("nmap -sU --top-ports 100 $TARGET -oN ${OUTPUT}-udp.txt");
}

sub full_scan {
    print "${GREEN}[+] Running Full Port Scan${NC}\n";
    system("nmap -p- -T4 $TARGET -oG ${OUTPUT}-full.gnmap");

    open my $fh, "<", "${OUTPUT}-full.gnmap" or return;
    my @ports;

    while (<$fh>) {
        if (/(\d+)\/open\//) {
            push @ports, $1;
        }
    }
    close $fh;

    if (@ports) {
        my $port_list = join(",", @ports);
        system("nmap -sC -sV -p $port_list $TARGET -oN ${OUTPUT}-full-detail.txt");
    }
}

sub vuln_scan {
    print "${GREEN}[+] Running Vulnerability Scan${NC}\n";
    system("nmap --script vuln $TARGET -oN ${OUTPUT}-vulns.txt");
}

sub all_scans {
    quick_scan();
    basic_scan();
    udp_scan();
    full_scan();
    vuln_scan();
}

# Main
check_args();

if ($TYPE =~ /^quick$/i) {
    quick_scan();
}
elsif ($TYPE =~ /^basic$/i) {
    basic_scan();
}
elsif ($TYPE =~ /^udp$/i) {
    udp_scan();
}
elsif ($TYPE =~ /^full$/i) {
    full_scan();
}
elsif ($TYPE =~ /^vulns$/i) {
    vuln_scan();
}
elsif ($TYPE =~ /^all$/i) {
    all_scans();
}
else {
    usage();
}
