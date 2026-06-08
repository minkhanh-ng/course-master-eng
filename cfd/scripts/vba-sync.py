import argparse
import sys
from pathlib import Path

import win32com.client

VBEXT_CT_STDMODULE = 1
VBEXT_CT_CLASSMODULE = 2
VBEXT_CT_MSFORM = 3
VBEXT_CT_DOCUMENT = 100


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def component_target_path(component, root_dir: Path) -> Path | None:
    name = component.Name
    component_type = component.Type

    if component_type == VBEXT_CT_STDMODULE:
        return root_dir / "Modules" / f"{name}.bas"
    if component_type == VBEXT_CT_CLASSMODULE:
        return root_dir / "Classes" / f"{name}.cls"
    if component_type == VBEXT_CT_MSFORM:
        return root_dir / "Forms" / f"{name}.frm"
    if component_type == VBEXT_CT_DOCUMENT:
        return root_dir / "Documents" / f"{name}.bas"

    return None


def export_project(vb_project, root_dir: Path) -> None:
    ensure_dir(root_dir / "Modules")
    ensure_dir(root_dir / "Classes")
    ensure_dir(root_dir / "Forms")
    ensure_dir(root_dir / "Documents")

    for component in vb_project.VBComponents:
        target_path = component_target_path(component, root_dir)
        if target_path is None:
            print(f"WARN: unsupported component type={component.Type}, name={component.Name}")
            continue

        ensure_dir(target_path.parent)

        if component.Type == VBEXT_CT_DOCUMENT:
            code_module = component.CodeModule
            line_count = code_module.CountOfLines
            code_text = code_module.Lines(1, line_count) if line_count > 0 else ""
            target_path.write_text(code_text, encoding="ascii", errors="ignore")
            continue

        if target_path.exists():
            target_path.unlink()

        component.Export(str(target_path))


def clear_importable_components(vb_project) -> None:
    for i in range(vb_project.VBComponents.Count, 0, -1):
        component = vb_project.VBComponents.Item(i)
        if component.Type in (VBEXT_CT_STDMODULE, VBEXT_CT_CLASSMODULE, VBEXT_CT_MSFORM):
            vb_project.VBComponents.Remove(component)


def import_files(vb_project, directory: Path, extension: str) -> None:
    if not directory.exists():
        return

    for path in sorted(directory.glob(f"*.{extension}")):
        vb_project.VBComponents.Import(str(path))


def apply_document_modules(vb_project, documents_dir: Path) -> None:
    if not documents_dir.exists():
        return

    for path in sorted(documents_dir.glob("*.bas")):
        module_name = path.stem
        try:
            component = vb_project.VBComponents.Item(module_name)
        except Exception:
            print(f"WARN: document module not found in workbook: {module_name}")
            continue

        content = path.read_text(encoding="ascii", errors="ignore")
        code_module = component.CodeModule
        line_count = code_module.CountOfLines

        if line_count > 0:
            code_module.DeleteLines(1, line_count)

        if content.strip():
            code_module.AddFromString(content)


def import_project(vb_project, root_dir: Path) -> None:
    clear_importable_components(vb_project)
    import_files(vb_project, root_dir / "Modules", "bas")
    import_files(vb_project, root_dir / "Classes", "cls")
    import_files(vb_project, root_dir / "Forms", "frm")
    apply_document_modules(vb_project, root_dir / "Documents")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Sync Excel VBA project with text files")
    parser.add_argument(
        "-a",
        "--action",
        choices=("export", "import", "sync"),
        default="sync",
        help="Operation to run",
    )
    parser.add_argument(
        "-w",
        "--workbook",
        default=str((Path(__file__).resolve().parent.parent / "CAL-SHEET-CFD-252.xlsm")),
        help="Path to .xlsm workbook",
    )
    parser.add_argument(
        "-s",
        "--src",
        default=str((Path(__file__).resolve().parent.parent / "vba-src")),
        help="VBA source folder",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    workbook_path = Path(args.workbook).resolve()
    source_dir = Path(args.src).resolve()

    if not workbook_path.exists():
        print(f"ERROR: workbook not found: {workbook_path}")
        return 1

    ensure_dir(source_dir)

    excel = None
    workbook = None

    try:
        excel = win32com.client.Dispatch("Excel.Application")
        excel.Visible = False
        excel.DisplayAlerts = False

        workbook = excel.Workbooks.Open(str(workbook_path))
        vb_project = workbook.VBProject

        if args.action in ("export", "sync"):
            export_project(vb_project, source_dir)

        if args.action in ("import", "sync"):
            import_project(vb_project, source_dir)
            workbook.Save()

        if args.action == "export":
            print(f"Export complete: {source_dir}")
        elif args.action == "import":
            print(f"Import complete and workbook saved: {workbook_path}")
        else:
            print("Sync complete (export + import) and workbook saved.")

        return 0
    except Exception as exc:
        message = str(exc)
        if "Programmatic access to Visual Basic Project is not trusted" in message:
            print(
                "ERROR: Excel blocked VBA project access. In Excel: File > Options > Trust Center > Trust Center Settings > Macro Settings > enable 'Trust access to the VBA project object model'."
            )
        else:
            print(f"ERROR: {message}")
        return 1
    finally:
        if workbook is not None:
            try:
                workbook.Close(SaveChanges=False)
            except Exception:
                pass

        if excel is not None:
            try:
                excel.Quit()
            except Exception:
                pass


if __name__ == "__main__":
    sys.exit(main())
