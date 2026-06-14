# VBA Source (vba-src)

This folder contains the exported VBA project files for the workbook used in this repository. The files are organized so you can edit VBA in VS Code and sync changes to/from the `.xlsm` workbook using the provided Python script.

**Structure**

- **Modules**: standard modules (`*.bas`) — shared procedures and functions.
- **Classes**: class modules (`*.cls`).
- **Forms**: userforms (`*.frm` and optional `.frx` binaries).
- **Documents**: document modules (`*.bas`) for `ThisWorkbook` and worksheet code-behinds.

**Quick Start**

1. Ensure Excel allows programmatic VBA access: File → Options → Trust Center → Trust Center Settings → Macro Settings → enable "Trust access to the VBA project object model".
2. From the repository root run the sync script to export current workbook code:

```powershell
python .\scripts\vba-sync.py --action export
```

3. Edit files in this folder using VS Code.
4. Import changes back into the workbook:

```powershell
python .\scripts\vba-sync.py --action import
```

5. For a full round-trip (export then import) use:

```powershell
python .\scripts\vba-sync.py --action sync
```

**Notes**

- The sync script will create `vba-src` if missing and will write document modules (ThisWorkbook/Sheet*) as plain `.bas` files in `Documents`.
- If Excel reports "Programmatic access to Visual Basic Project is not trusted", enable VBA project access in Excel (see step 1).
- Keep Excel closed or avoid interfering automation while running import/export to reduce COM lock issues.
- The workspace contains convenience VS Code tasks for export/import under the Tasks menu.

---
**File summaries**

- `Modules/M_Main.bas`: Core hydraulic manifold solver, optimization routine, report generation, and utility functions for path tracing and row calculations.
- `Modules/M_Colebrook.bas`: Colebrook–White friction factor solver (iterative) used for pipe friction calculations.
- `Modules/M_StartNode.bas`: Newton–Raphson solver to compute start-node density/mixture state for compressible flow calculations.
- `Modules/M_Utility.bas`: Small math helpers (`LogBase`, `PiNumber`).

- `Classes/I_PipeFitting.cls`: Interface declaring `Zeta` and `HeadLoss` properties for pipe fittings.
- `Classes/C_Tee_Cross.cls`: Implements tee/cross fitting head-loss models, supports selecting straight/branch path.
- `Classes/C_Elbow_Bend.cls`: Implements elbow/bend loss calculations based on curvature, angle, Reynolds number and roughness.
- `Classes/C_Conical_Transition.cls`: Implements conical diffuser/reducer models with interpolation tables for empirical diagrams.
