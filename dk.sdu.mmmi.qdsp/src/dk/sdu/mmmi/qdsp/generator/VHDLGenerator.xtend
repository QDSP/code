package dk.sdu.mmmi.qdsp.generator

import dk.sdu.mmmi.qdsp.structural.elements.Instruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.ADDInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BDIVInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BMULInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BREInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BRGInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BRLInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CAHInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CAIInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CASInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CHAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CIAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CMPInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CSAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.JMPInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.LDXInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.LSHInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MAXInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MINInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MULInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.NOPInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.RSHInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.RSTInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.SUBInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.TRNInstruction
import java.util.List
import dk.sdu.mmmi.qdsp.structural.Heap

class VHDLGenerator {
    private MySettings settings;
    private ResourcesValidator resourcesValidator;
    private QDSPGenerator generator;
//    private Instructions instructions;
    private Heap heap;
    private List<Instruction> muInsts;

    new(QDSPGenerator generator,MySettings settings, ResourcesValidator resourcesValidator, Heap heap, List<Instruction> muInsts){
        this.settings = settings;
        this.generator = generator;
        this.resourcesValidator = resourcesValidator;
        this.heap = heap;
        this.muInsts = muInsts;
    }
    
    def private String convertIDtoBinaryString(int instruction){
		var String binarized = Integer.toBinaryString(instruction);
		var int len = binarized.length();
		var int instructionLength = generator.instructionLength
		var String zeroes = "";
		for(int i: 0 ..< instructionLength){
			zeroes = zeroes + "0";
		}
		if (len < instructionLength) {
		  	binarized = zeroes.substring(0, instructionLength-len).concat(binarized)
		} else {
			binarized = binarized.substring(len - instructionLength)
		}
		return binarized;
    }
    
    def CharSequence getVHDL()'''
-- This QDSP3 is auto generated for the project «settings.projectName».
-- The first 2 versions of the QDSP was designed by Anders Stengaard
-- Soerensen MMMI at university of southern denmark.
--
-- The DSL project in auto generating the QDSP, and programming it in a proper
-- language, is made by Jon Henneberg jon@henneberg.cc and Anders Krauthammer
-- anders@krauthammer.dk as a part of the master education in robotics.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity «settings.projectName» is
    Port (
        clk_i : in  STD_LOGIC;

        SHmem_we_o      : out std_logic;
        SHmem_addr_o    : out std_logic_vector(5 downto 0);
        SHmem_data_o    : out std_logic_vector(31 downto 0);
        SHmem_data_i    : in std_logic_vector(31 downto 0);
        SHmem_w_ack_i   : in std_logic;
        SHmem_w_err_i   : in std_logic;

        IOmem_we_o      : out std_logic;
        IOmem_addr_o    : out std_logic_vector(5 downto 0);
        IOmem_data_o    : out std_logic_vector(31 downto 0);
        IOmem_data_i    : in std_logic_vector(31 downto 0)
    );
end «settings.projectName»;

architecture Behavioral of «settings.projectName» is

    «IF settings.RuntimeProgrammable»
    constant StatusAddress  : integer := «settings.ProgramingStatusAddress»;
    constant DataInAddress  : integer := «settings.ProgramingDataInAddress»;
    constant ControlAddress : integer := «settings.ProgramingControlAddress»;
    constant DataOutAddress : integer := «settings.ProgramingDataOutAddress»;
    «ENDIF»
    constant HeapSize : integer := «generator.heapSize»;
    constant ProgramSize : integer := «generator.programMemorySize»;

    constant InstructionSize : integer := «generator.instructionLength»;
    constant ProgramArgumentSize : integer := «settings.MicroInstArgumentSize»;
    constant ProgramCodeSize : integer := InstructionSize + ProgramArgumentSize;
    constant ProgramCounterSize : integer := 6;

    function N(x: Integer) return signed is
        begin
            return to_signed(x,32);
    end N;

    function A(x: integer) return unsigned is
        begin
            return to_unsigned(x,ProgramArgumentSize);
    end A;

    «IF settings.RuntimeProgrammable»
    constant FeaturekeySize : integer := 22;
    constant featurekey  : unsigned(FeaturekeySize-1 downto 0) := "«resourcesValidator.getFeaturekeyAsString()»";

    constant HeapValidationkeySize : integer := 10;
    constant ProgramValidationkeySize : integer := 22;
    constant ValidationkeySize : integer :=ProgramValidationkeySize + HeapValidationkeySize;
    constant validationkey  : unsigned(ValidationkeySize - 1 downto 0) := "«resourcesValidator.getValidationkeyAsString()»";

    «ENDIF»
-- Definition of instruction set
    subtype instr_t is unsigned(InstructionSize-1 downto 0);

    «IF muInsts.filter(typeof(NOPInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «NOPInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(NOPInstruction.getStaticID)»";       -- No OPeration
    «ENDIF»
    «IF muInsts.filter(typeof(CAHInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «CAHInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(CAHInstruction.getStaticID)»";       -- Copy Accumulator to Heap
    «ENDIF»
    «IF muInsts.filter(typeof(CHAInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «CHAInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(CHAInstruction.getStaticID)»";       -- Copy Heap to Accumulator
    «ENDIF»
    «IF muInsts.filter(typeof(RSTInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «RSTInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(RSTInstruction.getStaticID)»";       -- Restart program
    «ENDIF»
    «IF muInsts.filter(typeof(LDXInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «LDXInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(LDXInstruction.getStaticID)»";
    «ENDIF»
    «IF muInsts.filter(typeof(CASInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «CASInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(CASInstruction.getStaticID)»";       -- Copy Accumulator to Shared memory
    «ENDIF»
    «IF muInsts.filter(typeof(CSAInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «CSAInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(CSAInstruction.getStaticID)»";       -- Copy Shared memory to Accumulator
    «ENDIF»
    «IF muInsts.filter(typeof(CAIInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «CAIInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(CAIInstruction.getStaticID)»";       -- Copy Accumulator to IO memory
    «ENDIF»
    «IF muInsts.filter(typeof(CIAInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «CIAInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(CIAInstruction.getStaticID)»";       -- Copy IO memory to Accumulator
    «ENDIF»
    «IF muInsts.filter(typeof(ADDInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «ADDInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(ADDInstruction.getStaticID)»";       -- Add Heap to accumulator
    «ENDIF»
    «IF muInsts.filter(typeof(SUBInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «SUBInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(SUBInstruction.getStaticID)»";       -- Subtract heap from Accumulator
    «ENDIF»
    «IF muInsts.filter(typeof(BDIVInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «BDIVInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(BDIVInstruction.getStaticID)»";     -- Devides Accumulator with a power of 2 number
    «ENDIF»
    «IF muInsts.filter(typeof(BMULInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «BMULInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(BMULInstruction.getStaticID)»";     -- Multiplyes Accumulator with a power of 2 number
    «ENDIF»
    «IF muInsts.filter(typeof(MULInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «MULInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(MULInstruction.getStaticID)»";       -- Multiplyes Accumulator with Heap
    «ENDIF»
    «IF muInsts.filter(typeof(TRNInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «TRNInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(TRNInstruction.getStaticID)»";       -- Trunctate Accumulator to 16-bit
    «ENDIF»
    «IF muInsts.filter(typeof(MAXInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «MAXInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(MAXInstruction.getStaticID)»";       -- Limit accumulator beneath Heap
    «ENDIF»
    «IF muInsts.filter(typeof(MINInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «MINInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(MINInstruction.getStaticID)»";       -- Limit accumulator above Heap
    «ENDIF»
    «IF muInsts.filter(typeof(LSHInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «LSHInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(LSHInstruction.getStaticID)»";       -- Bit shift Accumulator left a number of times
    «ENDIF»
    «IF muInsts.filter(typeof(RSHInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «RSHInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(RSHInstruction.getStaticID)»";       -- Bit shift Accumulator right a number of times
    «ENDIF»
    «IF muInsts.filter(typeof(JMPInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «JMPInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(JMPInstruction.getStaticID)»";       -- Absolute Jump (sets program counter)
    «ENDIF»
    «IF muInsts.filter(typeof(BREInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «BREInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(BREInstruction.getStaticID)»";       -- Branch if equal
    «ENDIF»
    «IF muInsts.filter(typeof(BRGInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «BRGInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(BRGInstruction.getStaticID)»";       -- Branch if grater than
    «ENDIF»
    «IF muInsts.filter(typeof(BRLInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «BRLInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(BRLInstruction.getStaticID)»";       -- Branch if less than
    «ENDIF»
    «IF muInsts.filter(typeof(CMPInstruction)).size > 0 || settings.RuntimeProgrammable»
    constant «CMPInstruction.staticInstructionName»  : instr_t := "«convertIDtoBinaryString(CMPInstruction.getStaticID)»";       -- Compare Accumulator with Heap
    «ENDIF»

    -- Definition and content of program memory
    type heap_mem_t is ARRAY(0 to HeapSize-1) of signed(31 downto 0);
    signal reg_heap, dsp_heap«IF settings.RuntimeProgrammable», ld_heap«ENDIF» : heap_mem_t := (
        «FOR e: heap.getHeapElements()»
        «IF e.value != 0»
        «e.heapAddress» => N(«e.value»),    -- «e.name»
        «ENDIF»
        «ENDFOR»
        others => N(0)
    );

    type mem_prog_t is ARRAY(0 to ProgramSize-1) of unsigned(ProgramCodeSize - 1 downto 0);
    signal mem_prog : mem_prog_t := (
        «FOR i: 0 ..< muInsts.length»
«var m = muInsts.get(i)»
        «i» => «m.toString»,«IF m.comment != null» -- «m.comment» «ENDIF»
        «ENDFOR»
        others => NOP & A(0)
    );

    -- Processor signals
    signal reg_flags, nxt_flags                 : signed(2 downto 0)            := (others => '0');
    signal reg_accu, nxt_accu                   : signed(31 downto 0)           := (others => '0');
    signal reg_pcnt, nxt_pcnt                   : unsigned(6 downto 0)          := (others => '0');

    signal reg_shmem_we, nxt_shmem_we           : STD_LOGIC := '0';
    signal reg_shmem_addr, nxt_shmem_addr       : std_logic_vector(5 downto 0)  := (others => '0');
    signal reg_shmem_data, nxt_shmem_data       : std_logic_vector(31 downto 0) := (others => '0');

    signal reg_iomem_we, nxt_iomem_we           : STD_LOGIC := '0';
    signal reg_iomem_addr, nxt_iomem_addr       : std_logic_vector(5 downto 0)  := (others => '0');
    signal reg_iomem_data, nxt_iomem_data       : std_logic_vector(31 downto 0) := (others => '0');

    «IF settings.RuntimeProgrammable»
    -- Firmware loaders signals
    signal reg_loader_info, nxt_loader_info     : std_logic_vector(31 downto 0) := (others => '0');
    signal reg_loader_en, nxt_loader_en         : STD_LOGIC := '0';
    signal reg_ldmem_we, nxt_ldmem_we           : STD_LOGIC := '0';
    signal reg_ldmem_addr, nxt_ldmem_addr       : std_logic_vector(5 downto 0)  := (others => '0');
    signal reg_ldmem_data, nxt_ldmem_data       : std_logic_vector(31 downto 0) := (others => '0');

    signal reg_ld_control, nxt_ld_control       : unsigned(31 downto 0)         := (others => '0');
    signal reg_ld_data, nxt_ld_data             : unsigned(31 downto 0)         := (others => '0');
    signal reg_ld_status, nxt_ld_status         : unsigned(31 downto 0)         := (others => '0');

    signal reg_ld_validated, nxt_ld_validated   : STD_LOGIC                     := '0';

    type loader_states is (loader_idle, loader_enabled, request_control, request_data, read_control, read_data, write_status, write_data);
    signal reg_ldstate, nxt_ldstate : loader_states := loader_idle;

    attribute keep : string;
    attribute keep of reg_heap: signal is "true";
    attribute keep of ld_heap: signal is "true";
    attribute keep of dsp_heap: signal is "true";

    attribute keep of mem_prog: signal is "true";

    attribute keep of reg_accu: signal is "true";
    attribute keep of reg_pcnt: signal is "true";

    attribute keep of reg_shmem_we: signal is "true";
    attribute keep of reg_shmem_addr: signal is "true";
    attribute keep of reg_shmem_data: signal is "true";

    attribute keep of reg_iomem_we: signal is "true";
    attribute keep of reg_iomem_addr: signal is "true";
    attribute keep of reg_iomem_data: signal is "true";

    attribute keep of reg_loader_info: signal is "true";
    attribute keep of reg_loader_en: signal is "true";

    attribute keep of reg_ldmem_we: signal is "true";
    attribute keep of reg_ldmem_addr: signal is "true";
    attribute keep of reg_ldmem_data: signal is "true";

    «ENDIF»
begin

    shmem_we_o      <= «IF settings.RuntimeProgrammable»reg_ldmem_we  when reg_loader_en = '1' else«ENDIF» reg_shmem_we ;
    shmem_addr_o    <= «IF settings.RuntimeProgrammable»reg_ldmem_addr    when reg_loader_en = '1' else«ENDIF» reg_shmem_addr;
    shmem_data_o    <= «IF settings.RuntimeProgrammable»reg_ldmem_data    when reg_loader_en = '1' else«ENDIF» reg_shmem_data;

    iomem_we_o      <= reg_iomem_we;
    iomem_addr_o    <= reg_iomem_addr;
    iomem_data_o    <= reg_iomem_data;

«IF settings.RuntimeProgrammable»
-------------------------------
-- Loader Code
-------------------------------
    process(clk_i)
        begin
        if rising_edge(clk_i) then
            reg_ldstate <= nxt_ldstate;
            reg_loader_en <= nxt_loader_en;

            reg_ldmem_we <= nxt_ldmem_we;
            reg_ldmem_addr <= nxt_ldmem_addr;
            reg_ldmem_data <= nxt_ldmem_data;

            reg_ld_control <= nxt_ld_control;
            reg_ld_data <= nxt_ld_data;
            reg_ld_validated <= nxt_ld_validated;
            reg_ld_status <= nxt_ld_status;
        end if;
    end process;

    process(reg_ldmem_addr, reg_ldmem_data)
        variable mem_index : integer range 0 to ProgramSize;
        variable features  : unsigned(FeaturekeySize-1 downto 0);
        begin
            nxt_ldstate <= reg_ldstate;
            nxt_loader_en <= reg_loader_en;
            nxt_ld_data <= reg_ld_data;
            nxt_ld_control <= reg_ld_control;
            nxt_ld_validated <= reg_ld_validated;

            nxt_ldmem_we <= '0';
            nxt_ldmem_addr <= reg_ldmem_addr;
            nxt_ldmem_data <= reg_ldmem_data;

            mem_index := to_integer(reg_ld_control(23 downto 0));

            case reg_ldstate is
                when loader_idle =>
                    nxt_loader_en <= '0';
                    nxt_ld_validated <= '0';
                    if (reg_loader_info(31 downto 24) = X"81") then -- enable loader
                        nxt_loader_en <= '1';
                        nxt_ldstate <= request_control;
                    end if;

                when request_control =>
                    nxt_ldmem_addr <=  STD_LOGIC_VECTOR(A(ControlAddress)(5 downto 0));
                    nxt_ldstate <= request_data;

                when request_data =>
                    nxt_ldmem_addr <=  STD_LOGIC_VECTOR(A(DataOutAddress)(5 downto 0));
                    nxt_ldstate <= read_control;

                when read_control =>
                    nxt_ldstate <= read_data;
                    nxt_ld_control <= unsigned(shmem_data_i);

                when read_data =>
                    nxt_ldstate <= loader_enabled;
                    nxt_ld_data <= unsigned(shmem_data_i);

                when loader_enabled =>
                    nxt_ldstate <= write_status;
                    nxt_ld_status <= reg_ld_control;

                    case reg_ld_control(31 downto 24) is
                        when X"82"  => -- Stop Loader
                            nxt_ldstate <= loader_idle;

                        when X"83"  => -- Write Program
                            if (reg_ld_validated = '1') then
                                mem_prog(mem_index) <= reg_ld_data(ProgramCodeSize-1 downto 0);

                                nxt_ld_data <=  reg_ld_data;
                            end if;

                        when X"84"  => -- Read Program
                            nxt_ld_data(31 downto ProgramCodeSize-1)    <= (others => '0');
                            nxt_ld_data(ProgramCodeSize-1 downto 0) <=  mem_prog(mem_index);

                        when X"85"  => -- Write Heap
                            if (reg_ld_validated = '1') then
                                ld_heap(mem_index) <= signed(reg_ld_data);
                                nxt_ld_data <=  reg_ld_data;
                            end if;

                        when X"86"  => -- Read Heap
                            nxt_ld_data <=  unsigned(reg_heap(mem_index));

                        when X"87"  => -- Validate ID
                            nxt_ld_validated <= '1';
                            --Validate features
                            features := ((unsigned(reg_ld_control(FeaturekeySize-1 downto 0)) xor featurekey) and featurekey) xor (unsigned(reg_ld_control(FeaturekeySize-1 downto 0)) xor featurekey);
                            nxt_ld_status(FeaturekeySize-1 downto 0) <= not features;
                            if not (features = 0) then
                                nxt_ld_validated <= '0';
                            end if;

                            --Validate program size
                            if unsigned(shmem_data_i(ProgramValidationkeySize - 1 downto 0)) > validationkey(ProgramValidationkeySize - 1 downto 0) then
                                nxt_ld_validated <= '0';
                                nxt_ld_data(ProgramValidationkeySize - 1 downto 0) <= not unsigned(shmem_data_i(ProgramValidationkeySize - 1 downto 0)) - validationkey(ProgramValidationkeySize - 1 downto 0);
                            else
                                nxt_ld_data(ProgramValidationkeySize - 1  downto 0) <= (others => '1');
                            end if;

                            --Validate heap size
                            if unsigned(shmem_data_i(ValidationkeySize-1 downto ProgramValidationkeySize)) > validationkey(ValidationkeySize - 1 downto ProgramValidationkeySize) then
                                nxt_ld_validated <= '0';
                                nxt_ld_data(ValidationkeySize - 1 downto ProgramValidationkeySize) <= not unsigned(shmem_data_i(ValidationkeySize - 1 downto ProgramValidationkeySize)) - validationkey(ValidationkeySize - 1  downto ProgramValidationkeySize);
                            else
                                nxt_ld_data(ValidationkeySize - 1 downto ProgramValidationkeySize) <= (others => '1');
                            end if;

                        when others =>
                            nxt_ldstate <= request_control;
                    end case;
                when write_status =>
                    nxt_ldstate <= write_data;
                    nxt_ldmem_we    <= '1';
                    nxt_ldmem_addr <=  STD_LOGIC_VECTOR(A(StatusAddress)(5 downto 0));
                    nxt_ldmem_data  <=  STD_LOGIC_VECTOR(reg_ld_status);

                when write_data =>
                    nxt_ldstate <= request_control;
                    nxt_ldmem_we    <= '1';
                    nxt_ldmem_addr <=  STD_LOGIC_VECTOR(A(DataInAddress)(5 downto 0));
                    nxt_ldmem_data  <=  STD_LOGIC_VECTOR(reg_ld_data);

                when others =>
                    nxt_ldstate <= request_control;
            end case;

    end process;

    «ENDIF»
-------------------------------
-- DSP Code
-------------------------------
    process(clk_i)
        begin
            if rising_edge(clk_i) then
                «IF settings.RuntimeProgrammable»
                if (reg_loader_en = '1') then
                    reg_accu <= (others => '0');
                    reg_pcnt <= (others => '0');
                    reg_flags <= (others => '0');

                    reg_heap <= ld_heap;
                    reg_loader_info <= (others => '0');
                    --Shared memmory data
                    reg_shmem_we <= '0';
                    reg_shmem_addr <= (others => '0');
                    reg_shmem_data <= (others => '0');
                    --IO memmory data
                    reg_iomem_we <= '0';
                    reg_iomem_addr <= (others => '0');
                    reg_iomem_data <= (others => '0');
                else
                «ENDIF»
                    reg_accu <= nxt_accu;
                    reg_pcnt <= nxt_pcnt;
                    reg_flags <= nxt_flags;

                    reg_heap <= dsp_heap;
                    --Shared memmory data
                    reg_shmem_we <= nxt_shmem_we;
                    reg_shmem_addr <= nxt_shmem_addr;
                    reg_shmem_data <= nxt_shmem_data;
                    --IO memmory data
                    reg_iomem_we <= nxt_iomem_we;
                    reg_iomem_addr <= nxt_iomem_addr;
                    reg_iomem_data <= nxt_iomem_data;
                «IF settings.RuntimeProgrammable»
                    reg_loader_info <= nxt_loader_info;
                end if;
                «ENDIF»

            end if;
    end process;

    process(reg_accu, reg_pcnt)
        variable reg_instruction    : instr_t;
        variable reg_argument       : unsigned(ProgramArgumentSize - 1 downto 0);
        variable reg_index          : integer range 0 to HeapSize - 1;
        begin
            --Setup defaults
            nxt_accu <= reg_accu;
            nxt_flags <= reg_flags;
            nxt_pcnt <= reg_pcnt + 1;
            dsp_heap <= reg_heap;
            reg_instruction := mem_prog(to_integer(reg_pcnt))(ProgramCodeSize-1 downto ProgramArgumentSize);
            reg_argument := mem_prog(to_integer(reg_pcnt))(ProgramArgumentSize-1 downto 0);
            reg_index := to_integer(mem_prog(to_integer(reg_pcnt))(5 downto 0));
            «IF settings.RuntimeProgrammable»
            nxt_loader_info <= reg_loader_info;
            «ENDIF»
            --Shared memmory defaults
            nxt_shmem_we <= '0'; -- only write for one cycle
            nxt_shmem_addr <= reg_shmem_addr;
            nxt_shmem_data <= reg_shmem_data;
            --IO memmory defaults
            nxt_iomem_we <= '0'; -- only write for one cycle
            nxt_iomem_addr <= reg_iomem_addr;
            nxt_iomem_data <= reg_iomem_data;

            case reg_instruction is
            «IF muInsts.filter(typeof(RSTInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «RSTInstruction.staticInstructionName» =>
                nxt_PCNT <= (others => '0');

            «ENDIF»
            «IF muInsts.filter(typeof(RSHInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «RSHInstruction.staticInstructionName» => -- Shift Right
                nxt_accu(31 downto 0) <= (others => '0');
                nxt_accu((31-reg_index) downto 0) <= reg_accu(31 downto reg_index);

            «ENDIF»
            «IF muInsts.filter(typeof(LSHInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «LSHInstruction.staticInstructionName» => -- Shift Left
                nxt_accu(31 downto reg_index) <= reg_accu((31-reg_index) downto 0);
                nxt_accu(reg_index-1 downto 0) <= (others => '0');

            «ENDIF»
            «IF muInsts.filter(typeof(BDIVInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «BDIVInstruction.staticInstructionName» => -- Binary Devide
                nxt_accu(31 downto 0) <= (others => reg_accu(31));
                nxt_accu((31-reg_index) downto 0) <= reg_accu(31 downto reg_index);

            «ENDIF»
            «IF muInsts.filter(typeof(BMULInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «BMULInstruction.staticInstructionName» => -- Binary Multiply
                nxt_accu(31) <= reg_accu(31);
                nxt_accu(30 downto reg_index) <= reg_accu((30-reg_index) downto 0);
                nxt_accu(reg_index-1 downto 0) <= (others => '0');

            «ENDIF»
            «IF muInsts.filter(typeof(CAHInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «CAHInstruction.staticInstructionName» => -- Copy accumulator to heap
                dsp_heap(reg_index) <= reg_accu;

            «ENDIF»
            «IF muInsts.filter(typeof(CHAInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «CHAInstruction.staticInstructionName» =>
                nxt_accu <= reg_heap(reg_index);

            «ENDIF»
            «IF muInsts.filter(typeof(MAXInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «MAXInstruction.staticInstructionName» =>
                if reg_accu > reg_heap(reg_index) then
                    nxt_accu <= reg_heap(reg_index);
                end if;

            «ENDIF»
            «IF muInsts.filter(typeof(MINInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «MINInstruction.staticInstructionName» =>
                if reg_accu < reg_heap(reg_index) then
                    nxt_accu <= reg_heap(reg_index);
                end if;

            «ENDIF»
            «IF muInsts.filter(typeof(MULInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «MULInstruction.staticInstructionName» =>
                nxt_accu <= resize(reg_accu,16) * resize(reg_heap(reg_index),16);

            «ENDIF»
            «IF muInsts.filter(typeof(TRNInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «TRNInstruction.staticInstructionName» => -- Truncate to 16 bits
                if reg_accu > to_signed(32767, 32) then
                    nxt_accu <= to_signed(32767, 32);
                elsif reg_accu < to_signed(-32768, 32) then
                    nxt_accu <= to_signed(-32768, 32);
                end if;

            «ENDIF»
            «IF muInsts.filter(typeof(SUBInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «SUBInstruction.staticInstructionName» =>
                nxt_accu <= reg_accu - reg_heap(reg_index);

            «ENDIF»
            «IF muInsts.filter(typeof(ADDInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «ADDInstruction.staticInstructionName» =>
                nxt_accu <= reg_accu + reg_heap(reg_index);

            «ENDIF»
            «IF muInsts.filter(typeof(LDXInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «LDXInstruction.staticInstructionName» =>
                nxt_loader_info <= STD_LOGIC_VECTOR(reg_accu);

            «ENDIF»
            «IF muInsts.filter(typeof(CASInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «CASInstruction.staticInstructionName» =>
                nxt_shmem_we   <= '1';
                nxt_shmem_addr <= STD_LOGIC_VECTOR(reg_argument(5 downto 0));
                nxt_shmem_data <= STD_LOGIC_VECTOR(reg_accu);

            «ENDIF»
            «IF muInsts.filter(typeof(CSAInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «CSAInstruction.staticInstructionName» =>
                nxt_shmem_addr <= STD_LOGIC_VECTOR(reg_argument(5 downto 0));
                nxt_accu        <= signed(shmem_data_i);

            «ENDIF»
            «IF muInsts.filter(typeof(CAIInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «CAIInstruction.staticInstructionName» =>
                nxt_iomem_we    <= '1';
                nxt_iomem_addr <= STD_LOGIC_VECTOR(reg_argument(5 downto 0));
                nxt_iomem_data <= STD_LOGIC_VECTOR(reg_accu);

            «ENDIF»
            «IF muInsts.filter(typeof(CIAInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «CIAInstruction.staticInstructionName» =>
                nxt_iomem_addr <= STD_LOGIC_VECTOR(reg_argument(5 downto 0));
                nxt_accu        <= signed(iomem_data_i);

            «ENDIF»
            «IF muInsts.filter(typeof(CMPInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «CMPInstruction.staticInstructionName» =>
                if reg_accu = reg_heap(reg_index) then
                    nxt_flags <= (0 => '1', others => '0');
                elsif reg_accu < reg_heap(reg_index) then
                    nxt_flags <= (1 => '1', others => '0');
                elsif reg_accu > reg_heap(reg_index) then
                    nxt_flags <= (2 => '1', others => '0');
                end if;

            «ENDIF»
            «IF muInsts.filter(typeof(JMPInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «JMPInstruction.staticInstructionName» =>
                nxt_PCNT <= (others => '0');
                nxt_PCNT(ProgramCounterSize - 1 downto 0) <= reg_argument(ProgramCounterSize - 1 downto 0);

            «ENDIF»
            «IF muInsts.filter(typeof(BREInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «BREInstruction.staticInstructionName» =>
                if reg_flags(0) = '1' then
                    nxt_PCNT <= (others => '0');
                    nxt_PCNT(ProgramCounterSize - 1 downto 0) <= reg_argument(ProgramCounterSize - 1 downto 0);
                end if;

            «ENDIF»
            «IF muInsts.filter(typeof(BRLInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «BRLInstruction.staticInstructionName» =>
                if reg_flags(1) = '1' then
                    nxt_PCNT <= (others => '0');
                    nxt_PCNT(ProgramCounterSize - 1 downto 0) <= reg_argument(ProgramCounterSize - 1 downto 0);
                end if;

            «ENDIF»
            «IF muInsts.filter(typeof(BRGInstruction)).size > 0 || settings.RuntimeProgrammable»
            when «BRGInstruction.staticInstructionName» =>
                if reg_flags(2) = '1' then
                    nxt_PCNT <= (others => '0');
                    nxt_PCNT(ProgramCounterSize - 1 downto 0) <= reg_argument(ProgramCounterSize - 1 downto 0);
                end if;

            «ENDIF»
            when others =>
        end case;
    end process;
end Behavioral;
    '''
}