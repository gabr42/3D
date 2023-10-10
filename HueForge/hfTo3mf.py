# HueForge .hfp to PrusaSlicer .3mf converter
# Home: github.com/gabr42/3D/blob/master/HueForge/hfTo3mf.py
# Writen by Primož Gabrijelčič
# License: Freeware

import argparse
import zipfile
import json
from stl import mesh
import time

def unpack(v):
    x, y, z = v
    return (round(x, 6), round(y, 6), round(z, 6))

def addVertex(model, vertices, v, vert_idx):
    if not v in vertices:
        x, y, z = v
        model.append(f'    <vertex x="{x:.6f}" y="{y:.6f}" z="{z:.6f}"/>\n')
        vertices[v] = vert_idx
        return (vert_idx + 1)
    return vert_idx

def main():
    print ("hfTo3mf v0.1")
    start_time = time.time()
    parser = argparse.ArgumentParser()
    parser.add_argument("input_hf_path", type=str, help="Input HueForge file")

    # Parse command line    
    args = parser.parse_args()   
    input_hf_path = args.input_hf_path
    if not input_hf_path.endswith(".hfp"):
        input_hf_path += ".hfp"
    output_3mf_path = input_hf_path.replace(".hfp", ".3mf")

    # Read information from the .hfp file
    with open(input_hf_path, 'r', encoding='utf-8') as json_file:
        data = json.load(json_file)
    stl_path = data["stl"]
    base_layer_height = round(data["base_layer_height"], 2)
    layer_height = round(data["layer_height"], 2)
    filaments = data["filament_set"]
    sliders = data["slider_values"]

    # Create Prusa_Slicer_custom_gcode_per_print_z.xml
    layer_change = '<?xml version="1.0" encoding="utf-8"?>\n<custom_gcodes_per_print_z>\n'
    for index, slider in enumerate(sliders[:-1]):
        layer_change += '<code print_z="' + '{:.4f}'.format(base_layer_height + slider * layer_height, 2) + '" type="0" extruder="1" color="' + filaments[-index-2]["Color"] + '" extra="" gcode="M600"/>\n'
    layer_change += '<mode value="SingleExtruder"/>\n</custom_gcodes_per_print_z>\n'

    # Read the mesh data
    mesh_data = mesh.Mesh.from_file(stl_path)

    # Convert mesh data to the .3mf model (slow!)
    model = ['''<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" xmlns:slic3rpe="http://schemas.slic3r.org/3mf/2017/06">
<metadata name="slic3rpe:Version3mf">1</metadata>
<resources>
 <object id="1" type="model">
  <mesh>
   <vertices>
''']
    vertices = {}
    vert_idx = 0
    for triangle in mesh_data.vectors:
        v1, v2, v3 = triangle
        vert_idx = addVertex(model, vertices, unpack(v1), vert_idx)
        vert_idx = addVertex(model, vertices, unpack(v2), vert_idx)
        vert_idx = addVertex(model, vertices, unpack(v3), vert_idx)
    model.append('</vertices>\n')
    model.append('<triangles>\n')
    for triangle in mesh_data.vectors:
        v1, v2, v3 = triangle
        n1 = vertices[unpack(v1)]
        n2 = vertices[unpack(v2)]
        n3 = vertices[unpack(v3)]
        if (n1 != n2) and (n2 != n3) and (n3 != n1):
            model.append(f'    <triangle v1="{n1}" v2="{n2}" v3="{n3}"/>\n')
    model.append('''</triangles>
   </mesh>
  </object>
 </resources>
 <build>
  <item objectid="1" printable="1"/>
 </build>
</model>''')

    # Generate the .3mf file
    with zipfile.ZipFile(output_3mf_path, 'w',  compression=zipfile.ZIP_DEFLATED) as zipf:
        zipf.writestr("Metadata/Prusa_Slicer_custom_gcode_per_print_z.xml", layer_change)
        zipf.writestr("3D/3dmodel.model", ''.join(model))
        zipf.writestr("_rels/.rels", '<?xml version="1.0" encoding="UTF-8"?>\n'
                                    + '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
                                    + '<Relationship Target="/3D/3dmodel.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>\n'
                                    + '</Relationships>')
        zipf.writestr("Metadata/Slic3r_PE.config",  '; created by htTo3mf.py, github.com/gabr42/3D/blob/master/HueForge/hfTo3mf.py\n\n'
                                                 + f'; first_layer_height = {base_layer_height:.2f}\n' 
                                                 + f'; layer_height = {layer_height:.2f}\n'
                                                 + f'; min_layer_height = {layer_height:.2f}\n'
                                                 +  '; extruder_colour = ' + filaments[-1]["Color"] + '\n'
                                                 +  '; perimeters = 1\n'
                                                 +  '; bottom_fill_pattern = monotonic\n'
                                                 +  '; fill_density = 100%\n'
                                                 +  '; fill_pattern = rectilinear\n'
                                                 +  '; top_fill_pattern = alignedrectilinear\n')

    print("3mf file created successfully in ", round(time.time() - start_time), ' seconds')

if __name__ == "__main__":
    main() 