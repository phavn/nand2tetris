#!/usr/bin/python3

import sys
import argparse



def initialize():

    # name: value
    symbol_table = {"SP" : 0,
                   "LCL" :  1,
                   "ARG" : 2,
                   "THIS" : 3,
                   "THAT" : 4,
                   "R0" : 0,
                   "R1" : 1,
                   "R2" : 2,
                   "R3" : 3,
                   "R4" : 4,
                   "R5" : 5,
                   "R6" : 6,
                   "R7" : 7,
                   "R8" : 8,
                   "R9" : 9,
                   "R10" : 10,
                   "R11" : 11,
                   "R12" : 12,
                   "R13" : 13,
                   "R14" : 14,
                   "R15" : 15,
                   "SCREEN" : 16384,
                   "KBD" : 24576
        }

    return symbol_table


def remove_whitespaces_and_comments(asm_src_list):

    parsed_list = []

    for i in asm_src_list:

        # Append lined to parsed_list that are not empty lines and remove commented text after //
        if i.find('\n') == 0:
            pass
        elif i.find('//') == 0:
            pass
        elif i.find('//') > 0:
            comment_index = i.find('//')
            parsed_list.append((i[0:comment_index]).strip())
        else:
            parsed_list.append(i.strip())

    return parsed_list



# translate labels (loop labels) in (XXXXX) format. Insert XXXX to symbol_table with next instruction line #
def translate_labels(asm_src, symbol_table):

    counter = 0

    # asm_src[:] creates a new copy of list in memory
    for i in asm_src[:]:

        i = i.strip()
        last_index = int(len(i)-1)

        if i[0] == '(' and i[last_index] == ')':
            asm_src.remove(i)
            
            i = i[1:-1]
            symbol_table[i] = counter
            # Decreasing counter since label was removed from list
            counter=counter-1

        counter=counter+1

    return asm_src, symbol_table

# convert variables and loop labels to address numbers
def translate_symbols(asm_src, symbol_table):

    parsed_list = []
    starting_memory_address = 16

    # Loop 
    # find all @ symbols
    # if number, ignore
    # Check if it's already in symbol table
    # if not, add it
    # translate symbol to address

    # Replace symbols and labels with address number
    for i in asm_src:

        i = i.strip()

        if i.find('@') == 0:
            # symbol table check if not a number
            if not i[1:].isnumeric():

                # Add symbol to table with address starting at 16
                if i[1:] not in symbol_table:
                    symbol_table[i[1:]] = starting_memory_address
                    starting_memory_address = starting_memory_address + 1


                # translate symbols to addresses
                i = "@" + str(symbol_table[i[1:]])


        parsed_list.append(i)

    return parsed_list, symbol_table

# translate hack assembly code to hack machine language
def translate_program(asm_src, symbol_table, output_file):

    machine_src_list = []

    # file handler
    output_file_handler = open(output_file, "w")

    # JMP Masks
    jgt_mask = 0b0000000000000001
    jeq_mask = 0b0000000000000010
    jge_mask = 0b0000000000000011
    jlt_mask = 0b0000000000000100
    jne_mask = 0b0000000000000101
    jle_mask = 0b0000000000000110
    jmp_mask = 0b0000000000000111

    # Destination masks
    m_dest_mask = 0b0000000000001000
    d_dest_mask = 0b0000000000010000
    md_dest_mask = 0b0000000000011000
    a_dest_mask = 0b0000000000100000
    am_dest_mask = 0b0000000000101000
    ad_dest_mask = 0b0000000000110000
    amd_dest_mask = 0b0000000000111000


    # Arithmetic masks
    zero_alu_mask = 0b0000101010000000
    one_alu_mask = 0b0000111111000000
    negone_alu_mask = 0b0000111010000000
    d_alu_mask = 0b0000001100000000
    a_alu_mask = 0b0000110000000000
    notd_alu_mask = 0b0000001101000000
    nota_alu_mask = 0b0000110001000000
    negd_alu_mask = 0b0000001111000000
    nega_alu_mask = 0b0000110011000000
    inc_d_alu_mask = 0b0000011111000000
    inc_a_alu_mask = 0b0000110111000000
    dec_d_alu_mask = 0b0000001110000000
    dec_a_alu_mask = 0b0000110010000000
    d_plus_a_alu_mask = 0b0000000010000000
    d_minus_a_alu_mask = 0b0000010011000000
    a_minus_d_alu_mask = 0b0000000111000000
    d_and_a_alu_mask = 0b0000000000000000
    d_or_a_alu_mask = 0b0000010101000000
    m_src_mask = 0b0001000000000000  # Right side

    c_instruction_mask = 0b1000000000000000

    # loop through list, break it down to a and c instruction
    # A instruction code
        # everything that starts with @
    # C instruction code
        # split
        # jumps vs arithmetic
        # create machine language table
        # write binary to file

    for i in asm_src[:]:
        
        # A instruction
        if i.find('@') == 0:
            machine_language_instruction = format(int(i[1:]), '016b')
            # Write machine language A instruction to hack file
            output_file_handler.write(machine_language_instruction + '\n')

        # C instruction
        else:
            # Init instruction placeholder
            machine_language_instruction = 0b1110000000000000

            # JUMPS
            if i.find(';') >= 0:

                left, right = i.split(';')

                # Set jump machine language instruction based on jump mask
                if right == 'JGT':
                    machine_language_instruction = machine_language_instruction | jgt_mask
                elif right == 'JEQ':
                    machine_language_instruction = machine_language_instruction | jeq_mask
                elif right == 'JGE':
                    machine_language_instruction = machine_language_instruction | jge_mask
                elif right == 'JLT':
                    machine_language_instruction = machine_language_instruction | jlt_mask
                elif right == 'JNE':
                    machine_language_instruction = machine_language_instruction | jne_mask
                elif right == 'JLE':
                    machine_language_instruction = machine_language_instruction | jle_mask
                elif right == 'JMP':
                    machine_language_instruction = machine_language_instruction | jmp_mask

                # Set jump machine language instruction based on condition register or value
                if left == 'D':
                    machine_language_instruction = machine_language_instruction | d_alu_mask
                if left == '0':
                    machine_language_instruction = machine_language_instruction | zero_alu_mask


            # Arithmetics part
            if i.find('=') >=0 :

                left, right = i.split('=')
                
                # Set machine language mask based on right side of arithmetic C instruction
                if right == '0':
                    machine_language_instruction = machine_language_instruction | zero_alu_mask
                elif right == '1':
                    machine_language_instruction = machine_language_instruction | one_alu_mask
                elif right == '-1':
                    machine_language_instruction = machine_language_instruction | negone_alu_mask
                elif right == 'D':
                    machine_language_instruction = machine_language_instruction | d_alu_mask
                elif right == '!D':
                    machine_language_instruction = machine_language_instruction | notd_alu_mask
                elif right == 'A':
                    machine_language_instruction = machine_language_instruction | a_alu_mask
                elif right == '!A':
                    machine_language_instruction = machine_language_instruction | nota_alu_mask
                elif right == '-D':
                    machine_language_instruction = machine_language_instruction | negd_alu_mask
                elif right == '-A':
                    machine_language_instruction = machine_language_instruction | nega_alu_mask
                elif right == 'D+A':
                    machine_language_instruction = machine_language_instruction | d_plus_a_alu_mask
                elif right == 'D+1':
                    machine_language_instruction = machine_language_instruction | inc_d_alu_mask
                elif right == 'A+1':
                    machine_language_instruction = machine_language_instruction | inc_a_alu_mask
                elif right == 'D-1':
                    machine_language_instruction = machine_language_instruction | dec_d_alu_mask
                elif right == 'A-1':
                    machine_language_instruction = machine_language_instruction | dec_a_alu_mask
                elif right == 'D-A':
                    machine_language_instruction = machine_language_instruction | d_minus_a_alu_mask
                elif right == 'A-D':
                    machine_language_instruction = machine_language_instruction | a_minus_d_alu_mask
                elif right == 'D&A':
                    machine_language_instruction = machine_language_instruction | d_and_a_alu_mask
                elif right == 'D|A':
                    machine_language_instruction = machine_language_instruction | d_or_a_alu_mask
                # memory related operations
                elif right == 'M':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | a_alu_mask
                elif right == '!M':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | nota_alu_mask
                elif right == '-M':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | nega_alu_mask
                elif right == 'M+1':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | inc_a_alu_mask
                elif right == 'M-1':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | dec_a_alu_mask
                elif right == 'D+M':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | d_plus_a_alu_mask
                elif right == 'D-M':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | d_minus_a_alu_mask
                elif right == 'M-D':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | a_minus_d_alu_mask
                elif right == 'D&M':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | d_and_a_alu_mask
                elif right == 'D|M':
                    machine_language_instruction = machine_language_instruction | m_src_mask
                    machine_language_instruction = machine_language_instruction | d_or_a_alu_mask


                
                # Set machine language mask based on left side of arithmetic C instruction
                if left == 'D':
                    machine_language_instruction = machine_language_instruction | d_dest_mask
                elif left == 'M':
                    machine_language_instruction = machine_language_instruction | m_dest_mask
                elif left == 'A':
                    #machine_language_instruction = machine_language_instruction | a_alu_mask
                    machine_language_instruction = machine_language_instruction | a_dest_mask
                elif left == 'MD':
                    machine_language_instruction = machine_language_instruction | md_dest_mask
                elif left == 'AM':
                    machine_language_instruction = machine_language_instruction | am_dest_mask
                elif left == 'AD':
                    #machine_language_instruction = machine_language_instruction | a_alu_mask
                    machine_language_instruction = machine_language_instruction | ad_dest_mask
                elif left == 'AMD':
                    #machine_language_instruction = machine_language_instruction | a_alu_mask
                    machine_language_instruction = machine_language_instruction | amd_dest_mask


            # Write machine language C instruction to hack file
            machine_language_instruction = format(machine_language_instruction, '016b')
            #print(i +" "+ machine_language_instruction)
            output_file_handler.write(str(machine_language_instruction) + '\n')


    output_file_handler.close()
    return machine_src_list, symbol_table





# Parse file name argument
arg_parser = argparse.ArgumentParser(description='Compileshack asm files')
arg_parser.add_argument("--asm_file", "-a", required=True)
arg_parser.add_argument("--output_file", "-o", required=True)
args = arg_parser.parse_args()
asm_file  = args.asm_file
output_file = args.output_file

# Init symbol_table
symbol_table = initialize()
# asm source code list container
asm_file_list = []

# read asm file
asm_file_handler = open(asm_file, "r") 

# convert file into list
for line in asm_file_handler:
    asm_file_list.append(line)

asm_file_handler.close()

asm_file_list = remove_whitespaces_and_comments(asm_file_list)

asm_file_list, symbol_table = translate_labels(asm_file_list, symbol_table)

asm_file_list, symbol_table = translate_symbols(asm_file_list, symbol_table)

translate_program(asm_file_list, symbol_table, output_file)
