"""
Polygon-modeling script for the 3x3x3 Rubik's cube (run inside Blender).

Usage (headless):
    blender --background --python tools/blender/make_rubik.py

Outputs:
    tools/blender/rubik.blend   - editable Blender scene
    assets/rubik/rubik.glb      - glTF Binary used by the Flutter WebView (Three.js)

Workflow (= the "Polygon Modeling" pipeline of the presentation):
    1. Primitive cube  -> edit mode style operations with bmesh
    2. Bevel the edges -> rounded plastic body (black)
    3. Extrude/scale a thin slab -> colored sticker, bevelled too
    4. Duplicate for 27 cubies, parent stickers under their cubie
    5. Assign materials, export to glTF/GLB (Y-up)

Naming contract with Three.js (assets/rubik/rubik-src.js):
    cubie_<ix><iy><iz>   ix,iy,iz in {0,1,2}  (= game coord + 1)
        body_<ix><iy><iz>          black plastic
        sticker_<F>_<ix><iy><iz>   F in R L U D F B (only on outer faces)
Node names are unique on purpose: GLTFLoader renames duplicates (sticker_F ->
sticker_F_1, ...), which breaks lookups by exact name.
Game axes: +x = R, +y = U, +z = F (toward the camera).
Blender is Z-up, so game (x, y, z) -> Blender (x, -z, y);
the glTF exporter (Y-up) converts it back to game coords.
"""
import os
import sys
import bpy
import bmesh
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BLEND_OUT = os.path.join(ROOT, "tools", "blender", "rubik.blend")
GLB_OUT = os.path.join(ROOT, "assets", "rubik", "rubik.glb")

BODY_SIZE = 0.96          # cubie edge length (spacing between cubies = 1.0)
BODY_BEVEL = 0.07
BODY_BEVEL_SEGMENTS = 2
STICKER_SIZE = 0.80
STICKER_THICK = 0.04
STICKER_BEVEL = 0.05
STICKER_BEVEL_SEGMENTS = 2

# Face -> (outward direction in game coords)
FACES = {
    "R": (1, 0, 0), "L": (-1, 0, 0),
    "U": (0, 1, 0), "D": (0, -1, 0),
    "F": (0, 0, 1), "B": (0, 0, -1),
}
# Standard colors: U white, R red, F green, D yellow, L orange, B blue
FACE_COLORS = {
    "U": (1.0, 1.0, 1.0),
    "R": (0.898, 0.224, 0.208),
    "F": (0.180, 0.667, 0.310),
    "D": (1.0, 0.902, 0.0),
    "L": (1.0, 0.549, 0.0),
    "B": (0.082, 0.396, 0.753),
}


def game_to_blender(v):
    x, y, z = v
    return Vector((x, -z, y))


def clean_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    for block in (bpy.data.meshes, bpy.data.materials):
        for item in list(block):
            block.remove(item)


def make_material(name, rgb, roughness):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*rgb, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    mat.diffuse_color = (*rgb, 1.0)
    return mat


def beveled_box(name, size_xyz, bevel, segments):
    """Polygon modeling: primitive cube -> scale -> bevel all edges."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=Vector(size_xyz), verts=bm.verts)
    bmesh.ops.bevel(
        bm,
        geom=list(bm.edges),
        offset=bevel,
        segments=segments,
        profile=0.5,
        affect="EDGES",
    )
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    for poly in mesh.polygons:
        poly.use_smooth = True
    return mesh


def build():
    clean_scene()

    body_mat = make_material("plastic_black", (0.04, 0.04, 0.04), 0.45)
    sticker_mats = {
        f: make_material(f"sticker_{f}", rgb, 0.35) for f, rgb in FACE_COLORS.items()
    }

    body_mesh = beveled_box("body_mesh", (BODY_SIZE,) * 3, BODY_BEVEL, BODY_BEVEL_SEGMENTS)
    body_mesh.materials.append(body_mat)

    collection = bpy.context.scene.collection

    for gx in (-1, 0, 1):
        for gy in (-1, 0, 1):
            for gz in (-1, 0, 1):
                cubie_name = f"cubie_{gx + 1}{gy + 1}{gz + 1}"
                cubie = bpy.data.objects.new(cubie_name, None)  # empty = group node
                cubie.location = game_to_blender((gx, gy, gz))
                collection.objects.link(cubie)

                body = bpy.data.objects.new(f"body_{gx + 1}{gy + 1}{gz + 1}", body_mesh)  # shared mesh data
                body.parent = cubie
                collection.objects.link(body)

                for face, (dx, dy, dz) in FACES.items():
                    on_outer_face = (dx and gx == dx) or (dy and gy == dy) or (dz and gz == dz)
                    if not on_outer_face:
                        continue
                    # slab is thin along the face normal, wide along the other two axes
                    sx, sy, sz = (STICKER_SIZE if d == 0 else STICKER_THICK for d in (dx, dy, dz))
                    size = (sx, sz, sy)  # game (x, y, z) -> Blender local (x, z, y)
                    mesh = beveled_box(
                        f"sticker_mesh_{cubie_name}_{face}",
                        size,
                        STICKER_BEVEL if STICKER_BEVEL < STICKER_THICK * 1.4 else STICKER_THICK * 0.7,
                        STICKER_BEVEL_SEGMENTS,
                    )
                    mesh.materials.append(sticker_mats[face])
                    sticker = bpy.data.objects.new(f"sticker_{face}_{gx + 1}{gy + 1}{gz + 1}", mesh)
                    sticker.parent = cubie
                    # sit on the body surface, slightly embedded
                    offset = BODY_SIZE / 2 + STICKER_THICK / 2 - 0.012
                    sticker.location = game_to_blender((dx * offset, dy * offset, dz * offset))
                    collection.objects.link(sticker)


def export():
    os.makedirs(os.path.dirname(BLEND_OUT), exist_ok=True)
    os.makedirs(os.path.dirname(GLB_OUT), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
    bpy.ops.export_scene.gltf(
        filepath=GLB_OUT,
        export_format="GLB",
        export_yup=True,
        export_apply=True,
        export_materials="EXPORT",
        export_cameras=False,
        export_lights=False,
        export_extras=False,
    )
    print(f"[make_rubik] wrote {BLEND_OUT}")
    print(f"[make_rubik] wrote {GLB_OUT} ({os.path.getsize(GLB_OUT) / 1024:.0f} KB)")


if __name__ == "__main__":
    build()
    export()
