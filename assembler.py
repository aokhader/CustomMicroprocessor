import os
import re

def assemble(inputFilePath, lutFilePath, outputFilePath):
    '''
    Assembles assembly code into machine code. DOES NOT EXECUTE CODE; ONLY TRANSLATES.
    inputFile: path to assembly code file
    outputFile: path to output machine code file
    '''
    assembly_file = open(inputFilePath, 'r')
    lut_values = open(lutFilePath, 'w')
    machine_file = open(outputFilePath, 'w')

    # Copying the code from machine file to hardware mach_code
    hardware_root = os.path.split(outputFilePath)[0]
    match = re.search(r'program_(\d+)', outputFilePath)
    program_number = match.group(1) 
    hardware_path = os.path.join(hardware_root, f"p{program_number}_design", "mach_code.txt")
    hardware_machine_file = open(hardware_path, 'w')
    
    opcodes = {
        "mov": "000",
        "add": "001",
        "and": "010",
        "xor": "011",
        "lsr": "100",
        "ldm": "101",
        "ldi": "101",
        "str": "110",
        "br": "111",
        "bnz": "111"
    }

    constants_for_lut = {
        "program_1": [0x00, 0x01, 0x08, 0x10, 0x11, 0xFF, 0x80],
        "program_2": [0x00, 0x01, 0x08, 0xFF, 0x80],
        "program_3": [0x01, 0x08, 0xFF, 0x80]
    }

    if "program_1" in inputFilePath:
        for const in constants_for_lut["program_1"]:
            hex_value = hex(const)[2:].zfill(2)  # Get hex value of constant, pad to 2 digits
            lut_values.write(hex_value + "\n")
        
        if len(constants_for_lut["program_1"]) <= 10:
            # Pad remaining LUT entries with 0s
            for _ in range(10 - len(constants_for_lut["program_1"])):
                lut_values.write("00\n")
    
    elif "program_2" in inputFilePath:
        for const in constants_for_lut["program_2"]:
            hex_value = hex(const)[2:].zfill(2)  # Get hex value of constant, pad to 2 digits
            lut_values.write(hex_value + "\n")

        if len(constants_for_lut["program_2"]) <= 10:
            # Pad remaining LUT entries with 0s
            for _ in range(10 - len(constants_for_lut["program_2"])):
                lut_values.write("00\n")
    
    elif "program_3" in inputFilePath:
        for const in constants_for_lut["program_3"]:
            hex_value = hex(const)[2:].zfill(2)  # Get hex value of constant, pad to 2 digits
            lut_values.write(hex_value + "\n")

        if len(constants_for_lut["program_3"]) <= 4:
            # Pad remaining LUT entries with 0s
            for _ in range(4 - len(constants_for_lut["program_3"])):
                lut_values.write("00\n")


    assembly_code = list(assembly_file.read().split('\n'))
    line_number = 0

    for line in assembly_code:
        instruction = line.split()
        print(instruction)
        machine_code = ""

        if instruction == [] or instruction[0].startswith("#") or instruction[0].startswith(";"):
            # Skip empty lines and comments
            continue 

        if instruction[0].endswith(':'):
            # Store label address in LUT file
            # THE VERILOG WILL OPEN THIS FILE AND FILL THE LUT BEFORE RUNNING THE PROGRAM
            hex_value = hex(line_number)[2:].zfill(2)  # Get hex value of line number, pad to 2 digits
            lut_values.write(hex_value + "\n")
            
        elif instruction[0] in opcodes:
            # Translate instruction to machine code
            machine_code += opcodes[instruction[0]]

            if instruction[0] in ["mov", "add", "and", "xor", "lsr"]:
                # R-type instructions (2 registers) OOO RRR RRR
                # First register is the one we store result in
                first_register = instruction[1].replace('r', '').replace(',', '')
                first_register = bin(int(first_register))[2:] # convert to binary and remove 0b
                first_register = first_register.zfill(3)  # pad to 3 bits

                second_register = instruction[2].replace('r', '').replace(',', '')
                second_register = bin(int(second_register))[2:] # convert to binary and remove 0b
                second_register = second_register.zfill(3)  # pad to 3 bits

                machine_code = machine_code + first_register + second_register

            elif instruction[0] in ["ldm", "ldi"]:
                # OOO C AAAAA
                control_bit = '0' if instruction[0] == "ldm" else '1'
                machine_code += control_bit

                if instruction[0] == "ldm":
                    # Address is stored in a register
                    address = instruction[1].replace('r', '').replace(',', '')
                    address = bin(int(address))[2:] # convert to binary and remove 0b
                    address = address.zfill(5)  # pad to 5 bits
                    machine_code += address
                
                else:
                    # Address is a 5-bit immediate value
                    address = bin(int(instruction[1]))[2:].replace(',', '') # convert to binary and remove 0b
                    address = address.zfill(5)  # pad to 5 bits
                    machine_code += address

            elif instruction[0] == "str":
                # OOO R AAAAA
                register = '0' if instruction[1] == 'r0,' else '1'
                machine_code += register

                # Address is a 5-bit immediate value
                address = bin(int(instruction[2]))[2:].replace(',', '') # convert to binary and remove 0b
                address = address.zfill(5)  # pad to 5 bits
                machine_code += address
            
            elif instruction[0] in ["br", "bnz"]:
                # OOO C AAAAA
                control_bit = '0' if instruction[0] == "br" else '1'
                machine_code += control_bit

                # Address is a LUT index
                address = bin(int(instruction[1]))[2:].replace(',', '') # convert to binary and remove 0b
                address = address.zfill(5)  # pad to 5 bits
                machine_code += address

        print(machine_code)
        if machine_code != "":
            machine_file.write(machine_code + '\n')
            hardware_machine_file.write(machine_code + '\n')
            line_number += 1


# Assemble the three programs 
root = os.getcwd()
assemble(root + "/program_1/hamming.txt", root + "/program_1/LUT_values.hex", root + "/program_1/hm_machine.txt")
assemble(root + "/program_2/booth_multiply_assembly.txt", root + "/program_2/LUT_values.hex", root + "/program_2/booth_multiply_assembly.txt")
assemble(root + "/program_3/extended_multiply.txt", root + "/program_3/LUT_values.hex", root + "/program_3/mult3_machine.txt")
