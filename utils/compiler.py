import sys

INSTRUCTIONS = {
    'R-TYPE': {
        'SLL': {'funct': '000000'},
        'SRL': {'funct': '000010'},
        'SRA': {'funct': '000011'},
        'SLLV': {'funct': '000100'},
        'SRLV': {'funct': '000110'},
        'SRAV': {'funct': '000111'},
        'ADDU': {'funct': '100001'},
        'SUBU': {'funct': '100011'},
        'XOR': {'funct': '100110'},
        'AND': {'funct': '100100'},
        'OR': {'funct': '100101'},
        'NOR': {'funct': '100111'},
        'SLT': {'funct': '101010'},
    },
    'I-TYPE': {
        'MEMORY': {
            'LB': {'opcode': '100000'},
            'LH': {'opcode': '100001'},
            'LW': {'opcode': '100011'},
            'LWU': {'opcode': '100111'},
            'LBU': {'opcode': '100100'},
            'LHU': {'opcode': '100101'},
            'SB': {'opcode': '101000'},
            'SH': {'opcode': '101001'},
            'SW': {'opcode': '101011'}
        },
        'IMMEDIATE': {
            'ADDI': {'opcode': '001000'},
            'ANDI': {'opcode': '001100'},
            'ORI': {'opcode': '001101'},
            'XORI': {'opcode': '001110'},
            'LUI': {'opcode': '001111'},
            'SLTI': {'opcode': '001010'},
            'BEQ': {'opcode': '000100'},
            'BNE': {'opcode': '000101'}
        },
        'INST_INDEX': {
            'J': {'opcode': '000010'},
            'JAL': {'opcode': '000011'}
        }
    },
    'J-TYPE': {
        'JR': {'funct': '001000'},
        'JALR': {'funct': '001001'},
    }
}


def parse_arguments():
    if len(sys.argv) < 5 or '-i' not in sys.argv or '-o' not in sys.argv:
        print('Usage: python Assembler.py -i <inputfile.asm> -o <outputfile.hex>')
        sys.exit(2)
    input_file = sys.argv[sys.argv.index('-i') + 1]
    output_file_base = sys.argv[sys.argv.index('-o') + 1]
    return input_file, output_file_base


def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.readlines()


def process_lines(lines):
    return [line.strip().split() for line in lines]


def extract_labels(lines):
    labels = {}
    for index, line in enumerate(lines):
        if len(line) == 1 and line[0].lower() not in ['nop', 'halt']:
            labels[line[0].replace(':', '')] = index - len(labels)
    return labels


def remove_labels(lines):
    return [line for line in lines if len(line) > 1 or line[0].lower() in ['nop', 'halt']]


def format_binary(value, bits):
    return f'{value:0{bits}b}'


def assemble_instruction(instruction_name, operands, labels, line_index):
    if instruction_name in INSTRUCTIONS['R-TYPE']:
        return assemble_r_type(instruction_name, operands)
    elif instruction_name in INSTRUCTIONS['I-TYPE']['MEMORY']:
        return assemble_i_type_memory(instruction_name, operands)
    elif instruction_name in INSTRUCTIONS['I-TYPE']['IMMEDIATE']:
        return assemble_i_type_immediate(instruction_name, operands, labels, line_index)
    elif instruction_name in INSTRUCTIONS['I-TYPE']['INST_INDEX']:
        return assemble_i_type_index(instruction_name, operands, labels)
    elif instruction_name in INSTRUCTIONS['J-TYPE']:
        return assemble_j_type(instruction_name, operands)
    elif instruction_name.lower() == "halt":
        return "11111111111111111111111111111111"
    else:
        return "10101010101010101010101010101010"


def assemble_r_type(instruction_name, operands):
    op_code = "000000"
    shamt = "00000"
    function = INSTRUCTIONS['R-TYPE'][instruction_name]['funct']

    rd = format_binary(int(operands[0]), 5)
    if instruction_name in ['SLL', 'SRL', 'SRA']:
        rt = format_binary(int(operands[1]), 5)
        sa = format_binary(int(operands[2]), 5)
        return op_code + shamt + rt + rd + sa + function
    elif instruction_name in ['SLLV', 'SRLV', 'SRAV']:
        rt = format_binary(int(operands[1]), 5)
        rs = format_binary(int(operands[2]), 5)
        return op_code + rs + rt + rd + shamt + function
    else:
        rs = format_binary(int(operands[1]), 5)
        rt = format_binary(int(operands[2]), 5)
        return op_code + rs + rt + rd + shamt + function


def assemble_i_type_memory(instruction_name, operands):
    op_code = INSTRUCTIONS['I-TYPE']['MEMORY'][instruction_name]['opcode']
    rt = format_binary(int(operands[0]), 5)
    offset, base = map(int, operands[1].replace("(", " ").replace(")", "").split())
    offset = format_binary(offset & 0xffff, 16)
    base = format_binary(base, 5)
    return op_code + base + rt + offset


def assemble_i_type_immediate(instruction_name, operands, labels, line_index):
    print(instruction_name)
    print(operands)
    print(labels)
    print(line_index)
    op_code = INSTRUCTIONS['I-TYPE']['IMMEDIATE'][instruction_name]['opcode']
    if instruction_name in ['BEQ', 'BNE']:
        rs = format_binary(int(operands[0]), 5)
        rt = format_binary(int(operands[1]), 5)
    elif instruction_name == 'LUI':
        rs = "00000"
        rt = format_binary(int(operands[0]), 5)
    else:
        rt = format_binary(int(operands[0]), 5)
        rs = format_binary(int(operands[1]), 5)

    try:
        if instruction_name == 'LUI':
            immediate = format_binary(int(operands[1]) & 0xffff, 16)
        else:
            immediate = format_binary(int(operands[2]) & 0xffff, 16)
    except ValueError:
        offset = labels[operands[2]] - line_index - 1
        immediate = format_binary(offset & 0xffff, 16)

    return op_code + rs + rt + immediate


def assemble_i_type_index(instruction_name, operands, labels):
    op_code = INSTRUCTIONS['I-TYPE']['INST_INDEX'][instruction_name]['opcode']
    try:
        instr_index = format_binary(int(operands[0]), 26)
    except ValueError:
        instr_index = format_binary(labels[operands[0]], 26)
    return op_code + instr_index


def assemble_j_type(instruction_name, operands):
    op_code = "000000"
    function = INSTRUCTIONS['J-TYPE'][instruction_name]['funct']

    if instruction_name == 'JR':
        rs = format_binary(int(operands[0]), 5)
        zeros_15 = "000000000000000"
        return op_code + rs + zeros_15 + function
    elif instruction_name == 'JALR':
        if len(operands) == 1:
            rs = format_binary(int(operands[0]), 5)
            rd = format_binary(31, 5)
        else:
            rd = format_binary(int(operands[0]), 5)
            rs = format_binary(int(operands[1]), 5)
        zeros_5 = "00000"
        return op_code + rs + zeros_5 + rd + zeros_5 + function


def write_output_files(hex_file_path, bin_file_path, bin_txt_file_path, formatted_file_path, bin_bytes):
    with open(hex_file_path, 'w') as hex_file:
        hex_file.write("\n".join(bin_bytes['hexa']) + "\n")
    with open(bin_txt_file_path, 'w') as bin_txt_file:
        bin_txt_file.write("\n".join(bin_bytes['bin']) + "\n")
    with open(bin_file_path, 'wb') as bin_file:
        bin_file.write(bytearray(bin_bytes['bytes']))
    with open(formatted_file_path, 'w') as formatted_file:
        for i, instruction in enumerate(bin_bytes['bin']):
            formatted_file.write(f"ins_mem[{i}] = 32'b{instruction};\n")


def main():
    input_file_path, output_file_base = parse_arguments()
    output_file_path_hexa_txt = output_file_base + '_hex.txt'
    output_file_path_bin = output_file_base + '.bin'
    output_file_path_bin_txt = output_file_base + '_bin.txt'
    formatted_file_path = output_file_base + '_formatted.txt'

    input_lines = read_file(input_file_path)
    input_lines_list = process_lines(input_lines)
    labels = extract_labels(input_lines_list)
    input_lines_list = remove_labels(input_lines_list)

    bin_bytes = {'hexa': [], 'bin': [], 'bytes': []}

    for index, line in enumerate(input_lines_list):
        instruction_name = line[0]
        operands = [operand.replace("r", "").replace(",", "").replace("R", "") for operand in line[1:]]

        instruction_bin = assemble_instruction(instruction_name, operands, labels, index)
        instruction_hexa = f"{int(instruction_bin, 2):08x}"

        bin_bytes['bin'].append(instruction_bin)
        bin_bytes['hexa'].append(instruction_hexa)
        bin_bytes['bytes'].extend([int(instruction_bin[i:i+8], 2) for i in range(0, 32, 8)])

    write_output_files(output_file_path_hexa_txt, output_file_path_bin, output_file_path_bin_txt, formatted_file_path, bin_bytes)


if __name__ == "__main__":
    main()
