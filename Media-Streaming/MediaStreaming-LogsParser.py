
output_file_name = './file-output.txt' # file path of the parsed logs
input_file_name = './file-input.txt'  #file path of the raw logs

with open(output_file_name, 'w') as file:
    with open(input_file_name) as f:
        content = f.readlines()
    content = [x.strip() for x in content]
    for line in range(0, len(content)):
        if content[line].startswith("Total connections ="):
            file.write("\n"+content[line])
        elif content[line].startswith("Total errors ="):
            file.write("\n"+content[line])
        elif content[line].startswith("Percentage failure ="):
            file.write("\n"+content[line]+"\n")
    f.close()
