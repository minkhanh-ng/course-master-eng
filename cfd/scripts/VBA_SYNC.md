# VBA Workflow in VS Code for .xlsm

This project uses Excel as the workbook host and VS Code as the VBA editor.

## 1) One-time Excel settings

In Excel:

1. Open **File > Options > Trust Center > Trust Center Settings**.
2. Go to **Macro Settings**.
3. Enable **Trust access to the VBA project object model**.

Without this, export/import from script will fail.

## 2) Files and folders

- Workbook: `CAL-SHEET-CFD-252.xlsm`
- Python sync script: `scripts/vba-sync.py`
- VBA source folder (created automatically): `vba-src/`

The source layout is:

- `vba-src/Modules/*.bas`
- `vba-src/Classes/*.cls`
- `vba-src/Forms/*.frm` (+ `.frx` sidecar files)
- `vba-src/Documents/*.bas` (for `ThisWorkbook`, `Sheet1`, etc.)

## 3) Usage from terminal

Run from this workspace folder.

### Export workbook VBA to files

```powershell
python .\scripts\vba-sync.py --action export
```

### Import files back into workbook

```powershell
python .\scripts\vba-sync.py --action import
```

### Full sync (export then import)

```powershell
python .\scripts\vba-sync.py --action sync
```

## 4) One-click tasks in VS Code

This workspace includes task definitions in `.vscode/tasks.json`.

1. Open Command Palette.
2. Run **Tasks: Run Task**.
3. Choose `VBA: Export`, `VBA: Import`, or `VBA: Sync`.

## 5) Recommended daily flow

1. Run `export`.
2. Edit files in `vba-src` with VS Code.
3. Run `import`.
4. Open Excel and test macros.

## Notes

- Document modules (`ThisWorkbook`, `Sheet*`) are synced as plain code text in `vba-src/Documents`.
- Keep workbook and script closed from other automation tools while syncing to avoid COM lock issues.
