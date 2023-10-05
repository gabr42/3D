import argparse
import zipfile
import json
import re
import numpy as np
from stl import mesh

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_hf_path", type=str, help="Input HueForge file")
    
    args = parser.parse_args()   
    input_hf_path = args.input_hf_path
    if not input_hf_path.endswith(".hfp"):
        input_hf_path += ".hfp"
    output_3mf_path = input_hf_path.replace(".hfp", ".3mf")
    describe_path = input_hf_path.replace(".hfp", "_describe.txt")

    with open(input_hf_path, 'r', encoding='utf-8') as json_file:
        data = json.load(json_file)
    stl_path = data["stl"]

    with open(describe_path, 'r', encoding='utf-8') as file:
        description = file.read().splitlines()

    layer_change = '<?xml version="1.0" encoding="utf-8"?>\n<custom_gcodes_per_print_z>\n'
    layer_pattern = r'\(([\d.]+)mm\)'
    in_instructions = False
    for line in description:
        if in_instructions:
            if "At layer" in line:
                match = re.search(layer_pattern, line)
                if match:
                    layer_change += '<code print_z="' + match.group(1) + ' type="0" gcode="M600"/>\n'
        elif "Swap Instructions:" in line:
            in_instructions = True
    layer_change += '<mode value="SingleExtruder"/>\n</custom_gcodes_per_print_z>\n'

    mesh_data = mesh.Mesh.from_file(stl_path)

    # Save the data as an ASCII STL file
#    ascii_stl_file = "output_ascii.stl"
#    mesh_data.save(ascii_stl_file)

    with zipfile.ZipFile(output_3mf_path, 'w',  compression=zipfile.ZIP_DEFLATED) as zipf:
        zipf.writestr("Metadata/Prusa_Slicer_custom_gcode_per_print_z.xml", layer_change)
        zipf.write(stl_path, "3D/3dmodel.model")
        zipf.writestr("_rels/.rels", '<?xml version="1.0" encoding="UTF-8"?>\n'
                                    + '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
                                    + '<Relationship Target="/3D/3dmodel.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>\n'
                                    + '</Relationships>')

    print("3mf file created successfully.")

if __name__ == "__main__":
    main() 