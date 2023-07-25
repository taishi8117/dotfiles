#!/usr/bin/env python3

"""
TCP over TLS/443

[app] -> [socket] -> [lh-src] ==/TLS:443/==> [lh-dst] -> [socket] -> [app]
"""

import dns.resolver
import scapy.all as scapy
import netifaces as ni


def handle_packet_fn(iface, spoof_ip):
    def handle_packet(packet):
        ip = packet.getlayer(scapy.IP)
        tcp = packet.getlayer(scapy.TCP)

        print(tcp)

    return handle_packet


def _get_local_ip(iface):
    ni.ifaddresses(iface)
    return ni.ifaddresses(iface)[ni.AF_INET][0]["addr"]


def run(iface, local_ip, sniff_filter):
    print("#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#")
    print("-#-#-#-#-#-RUNNING LIGHTHOUSE-#-#-#-#-#-#")
    print("#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#")
    print("Interface:\t\t\t%s" % iface)
    print("Resolving to IP:\t\t%s" % local_ip)
    print("BPF sniff filter:\t\t%s" % sniff_filter)
    print("")
    print("Waiting for SSH requests...")

    scapy.sniff(
        iface=iface,
        filter=sniff_filter,
        prn=handle_packet_fn(iface, local_ip),
    )


IFACE = "wlp0s20f3"
local_ip = _get_local_ip(IFACE)

SNIFF_FILTER = "tcp port 22 && (dst %s || src %s)" % (local_ip, local_ip)

run(IFACE, local_ip, SNIFF_FILTER)
