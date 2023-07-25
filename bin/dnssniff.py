from datetime import datetime
from scapy.all import *

def process_pkt(packet):
    if packet.haslayer(DNSQR):
        timestamp = str(datetime.fromtimestamp(int(packet.time)))
        src_ip = packet[IP].src
        src_mac = packet[Ether].src
        dst_ip = packet[IP].dst
        dst_mac = packet[Ether].dst
        queried_domains = packet[DNSQR].qname.decode('utf-8')

        try:
            answers = [rr.rdata for rr in packet[DNS].an]
            answers = ', '.join(answers)
        except Exception:
            answers = ""

        print(f"{timestamp} [{src_ip:<15}->{dst_ip:<15}] {queried_domains} {answers}")

if __name__ == '__main__':
    print("Listening for packets...")
    sniff(iface='wlp0s20f3', prn=process_pkt, store=0)
