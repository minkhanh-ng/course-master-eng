Here is a structured To-Do list for writing the Python script to generate the CFD-ready `manifold.stl`.

To ensure watertight Boolean operations and proper patch naming (which is notoriously tricky in standard STLs), the best approach is to use **FreeCAD API** or **OpenSCAD (via SolidPython)** to generate separate ASCII STLs for each patch, and then concatenate them into a single file.

### Phase 1: Data Parsing & Topology Building

* [x] **Read CSV:** Load `pipe-system.csv` using `pandas`.
* [x] **Build Graph:** Replicate the `M_Main.bas` logic to map `Node In` to `Node Out` to establish the flow hierarchy.
* [x] **Calculate Node Coordinates:** Initialize Node `10` at `(0, 0, 0)`. Iterate through the DataFrame, calculating absolute coordinates for each subsequent node by accumulating `DeltaX`, `DeltaY`, and `DeltaZ`.

### Phase 2: Geometry Math & Filtering

* [x] **Filter Dummy Segments:** Identify elements with very short lengths (e.g., $L=0.01$ at elements `140`, `150`, `160`) that immediately follow elbows. Mark them to be skipped during the cylinder generation phase.
* [x] **Calculate Elbow Tangent Points:** - For elbows (e.g., `EL90_0.5`), the node represents the intersection of the two extension lines.
* Calculate the setback distance $T = R \cdot \tan(\theta/2)$. Since $\theta = 90^\circ$ and $R = 0.5 \cdot D_0$, $T = 0.5 \cdot D_0$.
* Offset the end of the incoming pipe and the start of the outgoing pipe by $T$ away from the elbow node.


* [x] **Define Reducer Endpoints:** For reducer components (`RC_L45`), map the start point with diameter `D0` and the end point with diameter `D1` directly to their respective `Node In` and `Node Out` coordinates. Ensure length validation $L = 4.5 \times |D_0 - D_1|$ aligns with the coordinate distance.

### Phase 3: Constructing 3D Primitives (Using FreeCAD API or OpenSCAD)

* [x] **Generate Straight Pipes:** Create cylinders for standard pipe elements. Start and end points must use the adjusted tangent points calculated in Phase 2 to prevent overlaps. Use diameter `D0`.
* [x] **Generate 4-Way Cross:** At Node `30 (C)`, create intersecting cylinders representing the main header and the left/right branches.
* [x] **Generate Elbows:** Create 90-degree torus segments (sweeps) at the elbow nodes (e.g., nodes `20`, `40`, `50`) with major radius $R=0.5 \cdot D_0$ and minor radius $D_0/2$. Position them to connect perfectly with the tangent points of the straight pipes.
* [x] **Generate Reducers:** Create frustums (cones with the tip cut off) between the reducer nodes, transitioning from diameter `D0` to `D1`.

### Phase 4: Boolean Operations & Boundary Extraction

* [x] **Union the Fluid Domain:** Perform a Boolean Union on all generated primitives (pipes, cross, elbows, reducers) to create a single, watertight internal fluid volume.
* [x] **Extract Boundary Patches:** Slice or extract the end-cap faces of the unified volume:
* Extract the face at Node `10` -> Label as `inlet`.
* Extract the faces at Nodes `33`, `43`, `53` -> Label as `outlet_33`, `outlet_43`, `outlet_53` respectively.
* The remaining exterior shell of the unioned body -> Label as `wall`.



### Phase 5: Exporting as Multi-Solid ASCII STL

*Note: Standard binary STLs do not support patch names. OpenFOAM requires multi-solid ASCII STLs.*

* [x] **Export Individual Patches:** Export `inlet`, `outlet_33`, `outlet_43`, `outlet_53`, and `wall` as separate ASCII STL files.
* [x] **Ensure ASCII Formatting:** Validate that each STL file begins with `solid <patch_name>` and ends with `endsolid <patch_name>`.
* [x] **Concatenate Files:** Write a Python routine to read all the individual ASCII STL files and append them into one final `manifold.stl` file. (e.g., `cat inlet.stl wall.stl outlet_33.stl ... > manifold.stl`).