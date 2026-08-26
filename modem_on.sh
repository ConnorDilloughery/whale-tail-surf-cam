#!/bin/bash
python3 -c "import serial; s=serial.Serial('/dev/ttyUSB2',115200,timeout=1); s.write(b'AT+CFUN=1\r\n'); s.close()"
