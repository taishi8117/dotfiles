#!/usr/bin/env

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


if __name__ == "__main__":
    arg = sys.argv[2] if len(sys.argv) >= 3 else None
    main(sys.argv[1], arg)
