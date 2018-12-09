
output_file_name = './file-output.txt' # file path of the parsed logs
input_file_name = './file-input.txt'  #file path of the raw logs

with open(output_file_name, 'w') as file:
    with open(input_file_name) as f:
        content = f.readlines()
    content = [x.strip() for x in content]
    isset = False
    for line in range(0, len(content)):
        if content[line].startswith("rps"):
            file.write("\n"+content[line]+"\n")
        elif "timeDiff" in content[line]:
            isset = True
            values = [x.strip() for x in content[line].split(",")]
            file.write(values[1] + " " + values[7] + " " + values[9] + "\n")
        elif isset:
            values = [x.strip() for x in content[line].split(",")]
            isset = False
            file.write(values[1]+ " " + values[7]+ " " + values[9] + "\n")
    f.close()
