#!/usr/bin/env python3

import sys
from datetime import datetime
import time


def main(cmd, arg):
    if cmd == "ts":
        if arg is None:
            ts = int(time.time())
        elif arg.startswith("0x"):
            ts = int(arg, 16)
        else:
            ts = int(arg)
        print("timestamp    :", ts)
        print("timestamp hex:", hex(ts))
        print("local time   :", datetime.fromtimestamp(ts).isoformat())
        print("utc time     :", datetime.utcfromtimestamp(ts).isoformat() + "Z")
    elif cmd == "hex":
        if arg is None:
            print(f"{cmd} <number>")
            return
        elif '.' in arg:
            num = float(arg)
        elif arg.startswith("0x"):
            num = int(arg, 16)
        else:
            num = int(arg)

        print("num            :", num)
        print("hex(num)       :", hex(int(num)))
        print("num * 1e18     :", int(num * 1e18))
        print("hex(num * 1e18):", hex(int(num * 1e18)))
        print("num / 1e18     :", num / 1e18)


if __name__ == "__main__":
    arg = sys.argv[2] if len(sys.argv) >= 3 else None
    main(sys.argv[1], arg)
