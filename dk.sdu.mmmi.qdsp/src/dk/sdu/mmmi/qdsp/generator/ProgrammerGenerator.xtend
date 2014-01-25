package dk.sdu.mmmi.qdsp.generator

class ProgrammerGenerator {
	private MySettings settings;
	
	new(MySettings settings){
        this.settings = settings;
    }
    
    def getPython()'''
'«»''
Created on 05/11/2013

@author: Jon
'«»''

import sys,binascii, serial, struct
try:
    from serial.tools.list_ports import comports
except ImportError:
    comports = None
DEFAULT_PORT = None
DEFAULT_BAUDRATE = «IF settings.shInterfaceType == SHInterfaceTypes.Unity
»3000000«ELSEIF settings.shInterfaceType == SHInterfaceTypes.uTosNet
»115200«ENDIF»

stdOutput = sys.stdout;
errOutput = sys.stderr;

def getports():
    if comports:
        sys.stderr.write('\n--- Available ports:\n')
        for port, desc, hwid in sorted(comports()):
            sys.stderr.write('--- %-20s %s\n' % (port, desc))


class TosNet(object):
    def __init__(self, port, baudrate):
        try:
            self.serial = serial.serial_for_url(port, baudrate, parity=serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE, timeout=5)
        except AttributeError:
            # happens when the installed pyserial is older than 2.5. use the Serial class directly then.
            self.serial = serial.Serial(port, baudrate, parity=serial.PARITY_ODD, timeout=1)

        print("Port opened",file=stdOutput)
«IF settings.shInterfaceType == SHInterfaceTypes.Unity»
#Program functions for Unity-Link
    def writeData(self, address, data):
        self.serial.write(bytearray("#W:{0:02x} {1:08x}\n".format(address, data & (2**32-1)),'ascii'))
        self.serial.flush()
        data = self.serial.readline()
        if data == b'#W\n':
            return True
        else:
            return False

    def readData(self, address):
        self.serial.flushInput()
        self.serial.write(bytearray("#R:{0:02x}\n".format(address),'ascii'))

        data = self.serial.readline()
        #Ensures that there are no remaining write confirmations in the input
        while data == b'#W\n':
            data = self.serial.readline()

        if len(data) == 12:
            var = binascii.unhexlify(data[3:11])
            x = struct.unpack('>l', var)[0]

            return x
        else:
            return None
«ELSEIF settings.shInterfaceType == SHInterfaceTypes.uTosNet»
#Program functions for uTosNet
    def writeData(self, address, data):
        self.serial.write(bytearray("w{0:02o} {1:08x}".format(address, data & (2**32-1)),'ascii'))
        self.serial.flush()

     def readData(self, address):
        self.serial.flushInput()
        self.serial.write(bytearray("r{0:02o}".format(address),'ascii'))

        data = self.serial.read(9)
        if len(data) == 9:
            var = binascii.unhexlify(data[:8])
            x = struct.unpack('>l', var)[0]

            return x
        else:
            return None
«ENDIF»
    def close(self):
        self.serial.close()
        print("Port closed",file=stdOutput)

class Header:
    pass

class Programmer(object):

    LOADER_START    = 0x81000000
    LOADER_STOP     = 0x82000000
    WRITE_PROGRAM   = 0x83000000
    READ_PROGRAM    = 0x84000000
    WRITE_HEAP      = 0x85000000
    READ_HEAP       = 0x86000000
    VALIDATE        = 0x87000000

    header = Header()


    def __init__(self, filename, port, baudrate):


        with open(filename, mode='rb') as file: # b is important -> binary
            self.fileContent = file.read()

        self.tosnet = TosNet(port, baudrate);

    def decodeHeadder(self):
        self.header.size = int(self.fileContent[0])
        if self.fileContent[0] == 18:
            self.header.adr_control, self.header.adr_dataout, self.header.adr_datain, self.header.adr_status, self.header.pcl, self.header.heap_cnt, self.header.pr_cnt, self.header.features,self.header.validatorkey = struct.unpack(">bbbbbhhii", self.fileContent[1:18])

            print("header data:",file=sys.stdout)
            print("\t{0:26s}: {1:d}".format('Status Address', self.header.adr_status),file=stdOutput)
            print("\t{0:26s}: {1:d}".format('DataIn Address', self.header.adr_datain),file=stdOutput)
            print("\t{0:26s}: {1:d}".format('DataOut Address', self.header.adr_dataout),file=stdOutput)
            print("\t{0:26s}: {1:d}".format('Control Address', self.header.adr_control),file=stdOutput)
            print("\t{0:26s}: {1:d}".format('Program Code Length (PCL)', self.header.pcl),file=stdOutput)
            print("\t{0:26s}: {1:d}".format('Heap Offset', self.header.heap_cnt),file=stdOutput)
            print("\t{0:26s}: {1:d}".format('Program Offset', self.header.pr_cnt),file=stdOutput)
            print("\t{0:26s}: 0b{1:022b}".format('Features', self.header.features),file=stdOutput)
            print("\t{0:26s}: {1:d}".format('Validator', self.header.validatorkey),file=stdOutput)

        else:
            sys.stderr.write('Unsupported header\n')

    def program(self):
        sys.stdout.write('Enabling loader\n')
        self.tosnet.writeData(self.header.adr_control, self.LOADER_START)

        if self.validate():
            self.writeHeap()
            self.writeProgram()
        sys.stdout.write('Enabling DSP\n')
        self.tosnet.writeData(self.header.adr_control, self.LOADER_STOP)

    def writeCommand(self, command, address, value):
        self.tosnet.writeData(self.header.adr_control, (command & 0xFF000000) | address)


        result = 0;
        while ((result & 0xFF000000) != command):
            result = self.tosnet.readData(self.header.adr_status)
            if result == None: break

        self.tosnet.writeData(self.header.adr_dataout, value)
        result = self.tosnet.readData(self.header.adr_datain)
        if (result == value):
            return True
        else:
            return False

    def writeHeap(self):
        for i in range(self.header.size,self.header.size + self.header.heap_cnt,5):
            address, value = struct.unpack(">bi", self.fileContent[i:i+5])
            if self.writeCommand(self.WRITE_HEAP, address, value) == False:
                print("\t failed to write {1} to heap[{0}]".format(address,value),file=stdOutput)

    def writeProgram(self):
        address = 0
        for i in range(self.header.size + self.header.heap_cnt,self.header.size + self.header.heap_cnt + self.header.pr_cnt,self.header.pcl):
            value = int.from_bytes(self.fileContent[i:i+self.header.pcl], 'big')
            if self.writeCommand(self.WRITE_PROGRAM, address, value) == False:
                print("\t failed to write {1} to prog[{0}]".format(address,value),file=stdOutput)
            address += 1

    def validate(self):
        print("Validating",file=stdOutput)
        self.tosnet.writeData(self.header.adr_control, ( self.VALIDATE & 0xFF000000) | self.header.features)


        result = 0;
        while ((result & 0xFF000000) !=  self.VALIDATE):
            result = self.tosnet.readData(self.header.adr_status)
            if result == None: break

        if (result & 0x00FFFFFF) != ((1 << 22) - 1):
            print("Features not compatible",file=errOutput)
            return False

        print("Features validated successfully",file=stdOutput)

        self.tosnet.writeData(self.header.adr_dataout, self.header.validatorkey)
        result = self.tosnet.readData(self.header.adr_datain)
        if result != -1:
            print("Sizes not compatible",file=errOutput)
            return False

        print("Sizes validated successfully",file=stdOutput)
        return True

    def close(self):
        self.tosnet.close();



def main():
    import optparse

    parser = optparse.OptionParser(
        usage = "%prog [options] file [port [baudrate]]",
        description = "QDSP Programmer - Tool to send binary qdsp program via TosNet / Unity"
    )

    group = optparse.OptionGroup(parser, "Port settings")

    group.add_option("-p", "--port",
        dest = "port",
        help = "port, a number or a device name.",
        default = DEFAULT_PORT
    )

    group.add_option("-b", "--baud",
        dest = "baudrate",
        action = "store",
        type = 'int',
        help = "set baud rate, default %default",
        default = DEFAULT_BAUDRATE
    )

    (options, args) = parser.parse_args()

    port = options.port
    baudrate = options.baudrate

    if args:
        file = args.pop(0)
    else:
        parser.error("filename must be provided")

    if args:
        if options.port is not None:
            parser.error("no arguments are allowed, options only when --port is given")
        port = args.pop(0)
        if args:
            try:
                baudrate = int(args[0])
            except ValueError:
                parser.error("baud rate must be a number, not %r" % args[0])
            args.pop(0)
        if args:
            parser.error("too many arguments")
    else:
        # noport given on command line -> ask user now
        if port is None:
            getports()
            port = input('Enter port name:')


    sys.stdout.write('--- port: %s, baud: %d, filename: %s\n' % (port, baudrate, file))

    p = Programmer(file,port,baudrate)
    p.decodeHeadder();
    p.program()
    p.close()

if __name__ == '__main__':
    main()
    '''
}
