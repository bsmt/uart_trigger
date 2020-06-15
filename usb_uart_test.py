import serial
import binascii

with serial.Serial("COM4", 38400, timeout=5) as s:
    print("sending sync")
    s.write(b"\x7f")
    print("recv")
    print(s.read(1))
    #print("sending read start")
    #s.write(b"\x11\xee")
    #s.write(b"\xee")
    #s.write(b"\x7f\x7f\x7f\x7f")
    #s.write(b"\x00\xff\x00\xff")
    #s.write(b"\x11\xee")
    #print("recv")   
    #print(binascii.hexlify(s.read(1)))