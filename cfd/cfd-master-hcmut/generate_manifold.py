#!/usr/bin/env python3
"""Reads the pipe-system CSV, reconstructs 3D
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
import re
from collections import defaultdict, deque
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, cast

import pandas as pd


MM_TO_M = 0.001
DEFAULT_ROOT_NODE = "10"
DEFAULT_SHORT_SEGMENT_THRESHOLD_M = 0.011


def compute_build_id(csv_path: Path) -> str:
    file_bytes = csv_path.read_bytes()
    digest = hashlib.sha1(file_bytes).hexdigest()[:8]
    mtime_ns = csv_path.stat().st_mtime_ns
    return f"{mtime_ns:x}-{digest}"


def _to_float(value: Any) -> float:
    if pd.isna(value):
        return float("nan")
    return float(value)


def normalize_node_label(value: Any) -> str:
    text = "" if pd.isna(value) else str(value).strip()
    if not text:
        return ""
    match = re.match(r"^(\d+)", text)
    return match.group(1) if match else text


def normalize_column_name(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", str(value).lower())


def lookup_column(df: pd.DataFrame, expected_name: str) -> str:
    expected = normalize_column_name(expected_name)
    candidates: list[str] = []
    for column_name in df.columns:
        normalized = normalize_column_name(column_name)
        if normalized == expected or normalized.startswith(expected):
            candidates.append(column_name)
    if not candidates:
        raise KeyError(f"Could not find a column matching {expected_name!r}")
    candidates.sort(key=lambda name: (len(normalize_column_name(name)), name))
    return candidates[0]


def vector_add(left: tuple[float, float, float], right: tuple[float, float, float]) -> tuple[float, float, float]:
    return (left[0] + right[0], left[1] + right[1], left[2] + right[2])


def vector_sub(left: tuple[float, float, float], right: tuple[float, float, float]) -> tuple[float, float, float]:
    return (left[0] - right[0], left[1] - right[1], left[2] - right[2])


def vector_scale(vector: tuple[float, float, float], factor: float) -> tuple[float, float, float]:
    return (vector[0] * factor, vector[1] * factor, vector[2] * factor)


def vector_length(vector: tuple[float, float, float]) -> float:
    return math.sqrt(vector[0] ** 2 + vector[1] ** 2 + vector[2] ** 2)


def vector_unit(vector: tuple[float, float, float]) -> tuple[float, float, float]:
    length = vector_length(vector)
    if length == 0:
        raise ValueError("Cannot normalize a zero-length vector")
    return vector_scale(vector, 1.0 / length)


def point_to_native(point: tuple[float, float, float]) -> tuple[float, float, float]:
    return (float(point[0]), float(point[1]), float(point[2]))


def clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def dot(left: tuple[float, float, float], right: tuple[float, float, float]) -> float:
    return left[0] * right[0] + left[1] * right[1] + left[2] * right[2]


def cross(left: tuple[float, float, float], right: tuple[float, float, float]) -> tuple[float, float, float]:
    return (
        left[1] * right[2] - left[2] * right[1],
        left[2] * right[0] - left[0] * right[2],
        left[0] * right[1] - left[1] * right[0],
    )


def rotate_about_axis(
    vector: tuple[float, float, float], axis_unit: tuple[float, float, float], angle_rad: float
) -> tuple[float, float, float]:
    cos_a = math.cos(angle_rad)
    sin_a = math.sin(angle_rad)
    term_a = vector_scale(vector, cos_a)
    term_b = vector_scale(cross(axis_unit, vector), sin_a)
    term_c = vector_scale(axis_unit, dot(axis_unit, vector) * (1.0 - cos_a))
    return point_to_native(vector_add(vector_add(term_a, term_b), term_c))


def coordinates_close(left: tuple[float, float, float], right: tuple[float, float, float], tolerance: float = 1e-9) -> bool:
    return all(abs(a - b) <= tolerance for a, b in zip(left, right))


def elbow_angle_deg(fit_type: str) -> float:
    match = re.search(r"EL(\d+(?:\.\d+)?)", fit_type.upper())
    return float(match.group(1)) if match else 90.0


def parse_elbow_radius_factor(fit_param: str, fit_type: str, fallback: float = 0.5) -> float:
    text = f"{fit_param} {fit_type}".upper()

    match = re.search(r"R\s*=\s*([0-9]*\.?[0-9]+)\s*D", text)
    if match:
        return float(match.group(1))

    match = re.search(r"EL\d+_([0-9]*\.?[0-9]+)", text)
    if match:
        return float(match.group(1))

    return fallback


def parse_reducer_length_factor(fit_param: str, fallback: float = 4.5) -> float:
    text = fit_param.upper()

    match = re.search(r"L\s*=\s*([0-9]*\.?[0-9]+)\s*\*\s*\(?\s*D0\s*-\s*D1\s*\)?", text)
    if match:
        return float(match.group(1))

    match = re.search(r"L\s*=\s*([0-9]*\.?[0-9]+)", text)
    if match:
        return float(match.group(1))

    return fallback


def classify_kind(fit_type: str, comp_type: str, assignment: str, length_m: float) -> str:
    fit_upper = fit_type.upper()
    comp_upper = comp_type.upper()
    assignment_upper = assignment.upper()

    if fit_upper.startswith("RC_") or "REDUC" in comp_upper or "OUTLET" in assignment_upper:
        return "reducer"
    if fit_upper.startswith("EL") or "ELBOW" in comp_upper:
        return "elbow"
    if fit_upper.startswith("4WD") or "CROSS" in comp_upper:
        return "cross"
    if length_m <= DEFAULT_SHORT_SEGMENT_THRESHOLD_M:
        return "dummy"
    return "straight"


@dataclass(frozen=True)
class NodeCoordinate:
    node: str
    label: str | None
    x_m: float
    y_m: float
    z_m: float


def load_pipe_system(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    element_column = lookup_column(df, "Element")
    node_in_column = lookup_column(df, "Node In")
    node_out_column = lookup_column(df, "Node Out")
    delta_x_column = lookup_column(df, "DeltaX")
    delta_y_column = lookup_column(df, "DeltaY")
    delta_z_column = lookup_column(df, "DeltaZ")
    fit_type_column = lookup_column(df, "Fit. Type")
    comp_type_column = lookup_column(df, "Comp. Type")
    assignment_column = lookup_column(df, "Assignment")
    fit_param_column = lookup_column(df, "Fit. Param")
    comp_param_column = lookup_column(df, "Comp. Param")
    d0_column = lookup_column(df, "D0")
    d1_column = lookup_column(df, "D1")

    df = df.copy()
    df["element_id"] = pd.to_numeric(df[element_column], errors="coerce").astype("Int64")
    df["node_in_id"] = df[node_in_column].map(normalize_node_label)
    df["node_out_id"] = df[node_out_column].map(normalize_node_label)
    df["node_in_label"] = df[node_in_column].fillna("").astype(str).str.extract(r"\((.*?)\)", expand=False)
    df["node_out_label"] = df[node_out_column].fillna("").astype(str).str.extract(r"\((.*?)\)", expand=False)
    df["delta_x_m"] = df[delta_x_column].map(_to_float)
    df["delta_y_m"] = df[delta_y_column].map(_to_float)
    df["delta_z_m"] = df[delta_z_column].map(_to_float)
    df["d0_mm"] = df[d0_column].map(_to_float)
    df["d1_mm"] = df[d1_column].map(_to_float)
    df["fit_type_text"] = df[fit_type_column].fillna("").astype(str).str.strip()
    df["comp_type_text"] = df[comp_type_column].fillna("").astype(str).str.strip()
    df["assignment_text"] = df[assignment_column].fillna("").astype(str).str.strip()
    df["fit_param_text"] = df[fit_param_column].fillna("").astype(str).str.strip()
    df["comp_param_text"] = df[comp_param_column].fillna("").astype(str).str.strip()
    df["length_m"] = (df["delta_x_m"] ** 2 + df["delta_y_m"] ** 2 + df["delta_z_m"] ** 2).pow(0.5)
    return df


def build_graph(df: pd.DataFrame, root_node: str = DEFAULT_ROOT_NODE) -> dict[str, Any]:
    outgoing_rows: dict[str, list[int]] = defaultdict(list)
    incoming_row_by_node: dict[str, int] = {}
    node_labels: dict[str, str | None] = {}

    for index, row in df.iterrows():
        row_index = int(cast(Any, index))
        node_in = str(cast(Any, row["node_in_id"]))
        node_out = str(cast(Any, row["node_out_id"]))
        if node_in:
            outgoing_rows[node_in].append(row_index)
            if node_in not in node_labels and row["node_in_label"]:
                node_labels[node_in] = str(row["node_in_label"])
        if node_out:
            if node_out in incoming_row_by_node and incoming_row_by_node[node_out] != row_index:
                raise ValueError(f"Node {node_out} has multiple incoming rows")
            incoming_row_by_node[node_out] = row_index
            if node_out not in node_labels and row["node_out_label"]:
                node_labels[node_out] = str(row["node_out_label"])

    if root_node not in outgoing_rows:
        raise ValueError(f"Root node {root_node} does not appear in the CSV")

    coords: dict[str, tuple[float, float, float]] = {root_node: (0.0, 0.0, 0.0)}
    queue: deque[str] = deque([root_node])
    visited_rows: set[int] = set()

    while queue:
        node = queue.popleft()
        start_coord = coords[node]
        for index in outgoing_rows.get(node, []):
            row = cast(Any, df.loc[int(index)])
            delta = (float(cast(Any, row["delta_x_m"])), float(cast(Any, row["delta_y_m"])), float(cast(Any, row["delta_z_m"])))
            child = str(cast(Any, row["node_out_id"]))
            child_coord = point_to_native(vector_add(start_coord, delta))

            if child in coords and not coordinates_close(coords[child], child_coord):
                raise ValueError(
                    f"Coordinate mismatch for node {child}: existing {coords[child]} vs computed {child_coord}"
                )

            if child not in coords:
                coords[child] = child_coord
                queue.append(child)

            visited_rows.add(index)

    missing_rows = [int(cast(Any, df.at[int(cast(Any, index)), "element_id"])) for index in df.index if int(cast(Any, index)) not in visited_rows]
    if missing_rows:
        raise ValueError(f"Could not reach all rows from root node {root_node}: {missing_rows}")

    return {
        "root_node": root_node,
        "coords": coords,
        "incoming_row_by_node": incoming_row_by_node,
        "outgoing_rows_by_node": dict(outgoing_rows),
        "node_labels": node_labels,
    }


def build_geometry(df: pd.DataFrame, graph: dict[str, Any], short_segment_threshold_m: float = DEFAULT_SHORT_SEGMENT_THRESHOLD_M) -> dict[str, Any]:
    coords: dict[str, tuple[float, float, float]] = graph["coords"]
    incoming_row_by_node: dict[str, int] = graph["incoming_row_by_node"]

    elbow_nodes: dict[str, dict[str, Any]] = {}
    for _, row in df.iterrows():
        kind = classify_kind(row["fit_type_text"], row["comp_type_text"], row["assignment_text"], row["length_m"])
        if kind != "elbow":
            continue

        elbow_node = str(row["node_in_id"])
        incoming_row_index = incoming_row_by_node.get(elbow_node)
        if incoming_row_index is None:
            raise ValueError(f"Elbow element {int(row['element_id'])} has no incoming row at node {elbow_node}")

        incoming_row = cast(Any, df.loc[int(incoming_row_index)])
        parent_node = str(cast(Any, incoming_row["node_in_id"]))
        incoming_direction = point_to_native(vector_unit(vector_sub(coords[elbow_node], coords[parent_node])))
        outgoing_direction = point_to_native(vector_unit(vector_sub(coords[str(cast(Any, row["node_out_id"]))], coords[elbow_node])))
        angle_deg = elbow_angle_deg(str(cast(Any, row["fit_type_text"])))
        radius_factor = parse_elbow_radius_factor(str(cast(Any, row["fit_param_text"])), str(cast(Any, row["fit_type_text"])))
        elbow_radius_m = float(float(cast(Any, row["d0_mm"])) * radius_factor * MM_TO_M)
        setback_m = float(elbow_radius_m * math.tan(math.radians(angle_deg) / 2.0))

        elbow_nodes[elbow_node] = {
            "element": int(cast(Any, row["element_id"])),
            "incoming_element": int(cast(Any, incoming_row["element_id"])),
            "parent_node": parent_node,
            "setback_m": setback_m,
            "radius_factor": radius_factor,
            "radius_m": elbow_radius_m,
            "d0_m": float(row["d0_mm"]) * MM_TO_M,
            "incoming_direction": incoming_direction,
            "outgoing_direction": outgoing_direction,
            "tangent_in_m": point_to_native(vector_sub(coords[elbow_node], vector_scale(incoming_direction, setback_m))),
            "tangent_out_m": point_to_native(vector_add(coords[elbow_node], vector_scale(outgoing_direction, setback_m))),
        }

    segments: list[dict[str, Any]] = []
    for _, row in df.iterrows():
        kind = classify_kind(row["fit_type_text"], row["comp_type_text"], row["assignment_text"], row["length_m"])
        node_in = str(row["node_in_id"])
        node_out = str(row["node_out_id"])
        start = coords[node_in]
        end = coords[node_out]
        trimmed_start = start
        trimmed_end = end

        if kind != "reducer":
            if node_in in elbow_nodes:
                trimmed_start = elbow_nodes[node_in]["tangent_out_m"]
            if node_out in elbow_nodes:
                trimmed_end = elbow_nodes[node_out]["tangent_in_m"]

        reducer_expected_length_m = None
        reducer_length_difference_m = None
        reducer_length_ok = None
        if kind == "reducer":
            length_factor = parse_reducer_length_factor(row["fit_param_text"])
            reducer_expected_length_m = float(length_factor * abs(float(cast(Any, row["d0_mm"])) - float(cast(Any, row["d1_mm"]))) * MM_TO_M)
            reducer_length_difference_m = float(float(cast(Any, row["length_m"])) - reducer_expected_length_m)
            reducer_length_ok = math.isclose(float(cast(Any, row["length_m"])), reducer_expected_length_m, abs_tol=1e-6)

        skip_for_cylinder = kind != "reducer" and float(cast(Any, row["length_m"])) <= short_segment_threshold_m

        segments.append(
            {
                "element": int(cast(Any, row["element_id"])),
                "node_in": node_in,
                "node_out": node_out,
                "fit_type": str(cast(Any, row["fit_type_text"])),
                "comp_type": str(cast(Any, row["comp_type_text"])),
                "assignment": str(cast(Any, row["assignment_text"])),
                "fit_param": str(cast(Any, row["fit_param_text"])),
                "comp_param": str(cast(Any, row["comp_param_text"])),
                "kind": kind,
                "length_m": float(cast(Any, row["length_m"])),
                "d0_m": float(cast(Any, row["d0_mm"])) * MM_TO_M,
                "d1_m": float(cast(Any, row["d1_mm"])) * MM_TO_M,
                "skip_for_cylinder": skip_for_cylinder,
                "start_m": point_to_native(start),
                "end_m": point_to_native(end),
                "trimmed_start_m": trimmed_start,
                "trimmed_end_m": trimmed_end,
                "elbow_node": node_in if kind == "elbow" else None,
                "tangent_in_m": elbow_nodes[node_in]["tangent_in_m"] if node_in in elbow_nodes else None,
                "tangent_out_m": elbow_nodes[node_in]["tangent_out_m"] if node_in in elbow_nodes else None,
                "setback_m": elbow_nodes[node_in]["setback_m"] if node_in in elbow_nodes else None,
                "reducer_expected_length_m": reducer_expected_length_m,
                "reducer_length_difference_m": reducer_length_difference_m,
                "reducer_length_ok": reducer_length_ok,
            }
        )

    return {"elbow_nodes": elbow_nodes, "segments": segments}


def _segment_point_as_tuple(segment: dict[str, Any], key: str) -> tuple[float, float, float]:
    raw = segment[key]
    return (float(raw[0]), float(raw[1]), float(raw[2]))


def _tuple3(raw: Any) -> tuple[float, float, float]:
    return (float(raw[0]), float(raw[1]), float(raw[2]))


def _vector_has_positive_projection(vector: tuple[float, float, float], direction: tuple[float, float, float]) -> bool:
    try:
        return dot(vector, vector_unit(direction)) > 1e-9
    except ValueError:
        return False


def _unit_from_points(start: tuple[float, float, float], end: tuple[float, float, float]) -> tuple[float, float, float] | None:
    vector = vector_sub(end, start)
    length = vector_length(vector)
    if length <= 1e-12:
        return None
    return point_to_native(vector_scale(vector, 1.0 / length))


def _segment_direction_from_node(segment: dict[str, Any], node: str, node_point: tuple[float, float, float]) -> tuple[float, float, float] | None:
    start = _segment_point_as_tuple(segment, "start_m")
    end = _segment_point_as_tuple(segment, "end_m")
    trimmed_start = _segment_point_as_tuple(segment, "trimmed_start_m")
    trimmed_end = _segment_point_as_tuple(segment, "trimmed_end_m")

    if node == segment["node_in"]:
        preferred = [trimmed_end, end]
    elif node == segment["node_out"]:
        preferred = [trimmed_start, start]
    else:
        return None

    for candidate in preferred:
        direction = _unit_from_points(node_point, candidate)
        if direction is not None:
            return direction
    return None


def _direction_aligned(left: tuple[float, float, float], right: tuple[float, float, float], tolerance: float = 0.995) -> bool:
    try:
        left_unit = vector_unit(left)
        right_unit = vector_unit(right)
    except ValueError:
        return False
    return dot(left_unit, right_unit) >= tolerance


def _dedupe_directions(directions: list[tuple[float, float, float]], dot_tolerance: float = 0.995) -> list[tuple[float, float, float]]:
    unique: list[tuple[float, float, float]] = []
    for direction in directions:
        keep = True
        for existing in unique:
            if abs(dot(direction, existing)) >= dot_tolerance:
                keep = False
                break
        if keep:
            unique.append(direction)
    return unique


def _elbow_arc_definition(
    node_point: tuple[float, float, float],
    incoming_direction: tuple[float, float, float],
    outgoing_direction: tuple[float, float, float],
    radius_m: float,
) -> dict[str, tuple[float, float, float] | float]:
    center = vector_add(node_point, vector_add(vector_scale(incoming_direction, -radius_m), vector_scale(outgoing_direction, radius_m)))

    start_point = point_to_native(vector_add(node_point, vector_scale(incoming_direction, -radius_m)))
    end_point = point_to_native(vector_add(node_point, vector_scale(outgoing_direction, radius_m)))

    return {
        "start_m": start_point,
        "end_m": end_point,
        "center_m": point_to_native(center),
        "radius_m": float(radius_m),
    }


def build_phase3_primitives(model: dict[str, Any], build_id: str | None = None) -> dict[str, Any]:
    segments = copy.deepcopy(model["segments"])
    node_points = {
        node["node"]: (float(node["x_m"]), float(node["y_m"]), float(node["z_m"]))
        for node in model["nodes"]
    }
    elbow_by_node_out: dict[str, dict[str, Any]] = {}
    for node, elbow in model["elbow_nodes"].items():
        elbow_by_node_out[str(node)] = elbow
    elbow_by_exit_node: dict[str, dict[str, Any]] = {}
    for segment in segments:
        if segment["kind"] != "elbow":
            continue
        elbow = elbow_by_node_out.get(str(segment["node_in"]))
        if elbow is None:
            continue
        elbow_by_exit_node[str(segment["node_out"])] = elbow

    primitives: list[dict[str, Any]] = []

    for segment in segments:
        if segment["kind"] == "elbow" or segment["kind"] == "reducer":
            continue
        if float(segment["length_m"]) <= 1e-9:
            continue

        start = _segment_point_as_tuple(segment, "start_m")
        end = _segment_point_as_tuple(segment, "end_m")

        upstream_elbow = elbow_by_node_out.get(str(segment["node_in"]))
        if upstream_elbow is not None:
            segment_direction = vector_sub(end, start)
            elbow_direction = _tuple3(upstream_elbow["outgoing_direction"])
            if _direction_aligned(segment_direction, elbow_direction):
                start = _tuple3(upstream_elbow["tangent_out_m"])

        upstream_exit_elbow = elbow_by_exit_node.get(str(segment["node_in"]))
        if upstream_exit_elbow is not None:
            segment_direction = vector_sub(end, start)
            elbow_direction = _tuple3(upstream_exit_elbow["outgoing_direction"])
            if _direction_aligned(segment_direction, elbow_direction):
                start = _tuple3(upstream_exit_elbow["tangent_out_m"])

        downstream_elbow = elbow_by_node_out.get(str(segment["node_out"]))
        if downstream_elbow is not None:
            segment_direction = vector_sub(end, start)
            elbow_direction = _tuple3(downstream_elbow["incoming_direction"])
            if _direction_aligned(segment_direction, elbow_direction):
                end = _tuple3(downstream_elbow["tangent_in_m"])

        if vector_length(vector_sub(end, start)) <= 1e-9:
            continue

        primitives.append(
            {
                "name": f"pipe_{segment['element']}",
                "type": "cylinder",
                "role": "pipe_segment",
                "radius_m": float(segment["d0_m"]) * 0.5,
                "start_m": start,
                "end_m": end,
            }
        )

    for node, elbow in model["elbow_nodes"].items():
        node_point = node_points[node]
        incoming_direction = (float(elbow["incoming_direction"][0]), float(elbow["incoming_direction"][1]), float(elbow["incoming_direction"][2]))
        outgoing_direction = (float(elbow["outgoing_direction"][0]), float(elbow["outgoing_direction"][1]), float(elbow["outgoing_direction"][2]))
        arc = _elbow_arc_definition(node_point, incoming_direction, outgoing_direction, float(elbow["radius_m"]))
        arc_start = cast(tuple[float, float, float], arc["start_m"])
        arc_end = cast(tuple[float, float, float], arc["end_m"])
        arc_center = cast(tuple[float, float, float], arc["center_m"])
        arc_bend_radius = float(cast(float, arc["radius_m"]))
        arc_tube_radius = float(elbow["d0_m"]) * 0.5

        if vector_length(vector_sub(arc_end, arc_start)) > 1e-9:
            primitives.append(
                {
                    "name": f"elbow_{node}",
                    "type": "elbow_sweep",
                    "role": "elbow_sweep",
                    "corner_m": node_point,
                    "incoming_direction": incoming_direction,
                    "outgoing_direction": outgoing_direction,
                    "arc_start_m": arc_start,
                    "arc_end_m": arc_end,
                    "arc_center_m": arc_center,
                    "arc_bend_radius_m": arc_bend_radius,
                    "arc_tube_radius_m": arc_tube_radius,
                    "start_m": arc_start,
                    "end_m": arc_end,
                }
            )

    # Some elbow rows include long straight continuation in the same element
    # (e.g. from elbow tangent-out toward node_out). Generate that as pipe.
    for segment in segments:
        if segment["kind"] != "elbow":
            continue

        # If element centerline length exceeds elbow setback, the remaining
        # part is straight continuation from tangent-out to node_out.
        element_length = float(segment["length_m"])
        setback = float(segment.get("setback_m") or 0.0)
        if element_length <= setback + 1e-9:
            continue

        start = _segment_point_as_tuple(segment, "trimmed_start_m")
        end = _segment_point_as_tuple(segment, "end_m")
        if vector_length(vector_sub(end, start)) <= 1e-9:
            continue

        primitives.append(
            {
                "name": f"pipe_{segment['element']}_after_elbow",
                "type": "cylinder",
                "radius_m": float(segment["d0_m"]) * 0.5,
                "start_m": start,
                "end_m": end,
            }
        )

    for segment in segments:
        if segment["kind"] != "reducer":
            continue
        start = _segment_point_as_tuple(segment, "start_m")
        end = _segment_point_as_tuple(segment, "end_m")
        if vector_length(vector_sub(end, start)) <= 1e-9:
            continue
        primitives.append(
            {
                "name": f"reducer_{segment['element']}",
                "type": "cone",
                "role": "reducer",
                "radius1_m": float(segment["d0_m"]) * 0.5,
                "radius2_m": float(segment["d1_m"]) * 0.5,
                "start_m": start,
                "end_m": end,
            }
        )

    return {
        "root_node": model["root_node"],
        "build_id": build_id or "unknown",
        "patch_targets": {
            name: list(node_points[node_id])
            for name, node_id in {
                "inlet": "10",
                "outlet_33": "33",
                "outlet_43": "43",
                "outlet_53": "53",
            }.items()
            if node_id in node_points
        },
        "counts": {
            "primitives": len(primitives),
            "elbows": len(model["elbow_nodes"]),
            "reducers": sum(1 for segment in segments if segment["kind"] == "reducer"),
            "pipes": sum(1 for primitive in primitives if primitive.get("role") == "pipe_segment"),
        },
        "primitives": primitives,
    }


def write_phase3_freecad_macro(primitives_model: dict[str, Any], macro_path: Path, document_name: str = "Manifold") -> None:
    payload = json.dumps(primitives_model["primitives"], indent=2)
    patch_targets_payload = json.dumps(primitives_model.get("patch_targets", {}), indent=2)
    base_name = macro_path.stem
    build_id = str(primitives_model.get("build_id", "unknown"))
    macro_text = f'''# Auto-generated by generate_manifold.py (Phase 3-5)
import math
import os
import time
import FreeCAD as App
import Part
from FreeCAD import Vector

PRIMITIVES = {payload}
PATCH_TARGETS = {patch_targets_payload}
BASE_NAME = "{base_name}"
BUILD_ID = "{build_id}"
SAVE_FCSTD = os.environ.get("MANIFOLD_SAVE_FCSTD", "0").strip().lower() in {"1", "true", "yes"}
STL_DEFLECTION = float(os.environ.get("MANIFOLD_STL_DEFLECTION", "0.01"))


def _safe_name(name: str, used: set[str]) -> str:
    cleaned = "".join(ch if ch.isalnum() or ch == "_" else "_" for ch in name)
    if not cleaned:
        cleaned = "primitive"
    if cleaned[0].isdigit():
        cleaned = "p_" + cleaned
    base = cleaned
    i = 1
    while cleaned in used:
        i += 1
        cleaned = f"{{base}}_{{i}}"
    used.add(cleaned)
    return cleaned


def _vector(point):
    return Vector(float(point[0]), float(point[1]), float(point[2]))


def _cylinder_between(start, end, radius):
    axis = end - start
    height = axis.Length
    if height <= 1e-9:
        return None
    return Part.makeCylinder(float(radius), height, start, axis)


def _cone_between(start, end, r1, r2):
    axis = end - start
    height = axis.Length
    if height <= 1e-9:
        return None
    return Part.makeCone(float(r1), float(r2), height, start, axis)


def _clamp(value, low, high):
    return max(low, min(high, value))


def _distance(a, b):
    return (a - b).Length


def _is_planar(face):
    return hasattr(face, "Surface") and face.Surface.__class__.__name__ == "Plane"


def _extract_patch_faces(union_shape):
    all_faces = list(union_shape.Faces)
    picked = {{}}
    picked_indices = set()

    for patch_name, point in PATCH_TARGETS.items():
        target = _vector(point)
        best_index = None
        best_distance = float("inf")

        for face_index, face in enumerate(all_faces):
            if face_index in picked_indices:
                continue
            distance = _distance(face.CenterOfMass, target)
            if distance < best_distance:
                best_distance = distance
                best_index = face_index

        if best_index is not None:
            picked[patch_name] = all_faces[best_index]
            picked_indices.add(best_index)

    wall_faces = [face for index, face in enumerate(all_faces) if index not in picked_indices]
    return picked, wall_faces


def _rotate_about_axis(vector, axis_unit, angle_rad):
    cos_a = math.cos(angle_rad)
    sin_a = math.sin(angle_rad)
    term_a = vector * cos_a
    term_b = axis_unit.cross(vector) * sin_a
    term_c = axis_unit * (axis_unit.dot(vector) * (1.0 - cos_a))
    return term_a + term_b + term_c


def _make_elbow_sweep(start_point, end_point, center_point, bend_radius, tube_radius):
    start = _vector(start_point)
    end = _vector(end_point)
    center = _vector(center_point)

    start_vec = start - center
    end_vec = end - center
    if start_vec.Length <= 1e-9 or end_vec.Length <= 1e-9:
        return None

    normal = start_vec.cross(end_vec)
    if normal.Length <= 1e-9:
        return None
    normal.normalize()

    # Optional consistency check: start/end should be on bend radius from center.
    if abs(start_vec.Length - float(bend_radius)) > 1e-5 or abs(end_vec.Length - float(bend_radius)) > 1e-5:
        return None

    start_unit = start_vec / start_vec.Length
    end_unit = end_vec / end_vec.Length
    angle = math.acos(_clamp(start_unit.dot(end_unit), -1.0, 1.0))
    mid_vec = _rotate_about_axis(start_vec, normal, 0.5 * angle)
    mid = center + mid_vec

    arc_edge = Part.Arc(start, mid, end).toShape()
    path_wire = Part.Wire([arc_edge])

    tangent = normal.cross(start_vec)
    if tangent.Length <= 1e-9:
        tangent = end - start
    # Ensure tangent direction points from start toward end along the arc.
    if tangent.Length > 1e-9 and tangent.dot(end - start) < 0:
        tangent = tangent * -1.0
    if tangent.Length <= 1e-9:
        return None

    profile = Part.Wire([Part.Circle(start, tangent, float(tube_radius)).toShape()])
    return path_wire.makePipeShell([profile], True, True)


def _triangle_normal(a, b, c):
    normal = (b - a).cross(c - a)
    if normal.Length <= 1e-12:
        return Vector(0.0, 0.0, 0.0)
    normal.normalize()
    return normal


def _shape_triangles(shape, deflection=None):
    if deflection is None:
        deflection = STL_DEFLECTION
    points, facets = shape.tessellate(float(deflection))
    for facet in facets:
        yield points[facet[0]], points[facet[1]], points[facet[2]]


def _write_ascii_stl(shape, output_path, solid_name, deflection=None):
    triangle_count = 0
    with open(output_path, "w", encoding="ascii", newline="\\n") as handle:
        handle.write("solid %s\\n" % solid_name)
        for a, b, c in _shape_triangles(shape, deflection=deflection):
            triangle_count += 1
            normal = _triangle_normal(a, b, c)
            handle.write("  facet normal %.9e %.9e %.9e\\n" % (normal.x, normal.y, normal.z))
            handle.write("    outer loop\\n")
            handle.write("      vertex %.9e %.9e %.9e\\n" % (a.x, a.y, a.z))
            handle.write("      vertex %.9e %.9e %.9e\\n" % (b.x, b.y, b.z))
            handle.write("      vertex %.9e %.9e %.9e\\n" % (c.x, c.y, c.z))
            handle.write("    endloop\\n")
            handle.write("  endfacet\\n")
        handle.write("endsolid %s\\n" % solid_name)
    return triangle_count


def _concat_ascii_stls(output_path, input_paths):
    with open(output_path, "w", encoding="ascii", newline="\\n") as out_handle:
        for path in input_paths:
            if not os.path.isfile(path):
                continue
            with open(path, "r", encoding="ascii", errors="ignore") as in_handle:
                content = in_handle.read()
            out_handle.write(content)
            if not content.endswith("\\n"):
                out_handle.write("\\n")


doc = App.newDocument("{document_name}_" + BUILD_ID)
created = []
used_names = set()

for primitive in PRIMITIVES:
    ptype = primitive.get("type")
    shape = None
    start = _vector(primitive["start_m"])
    end = _vector(primitive["end_m"])

    if ptype == "cylinder":
        shape = _cylinder_between(start, end, primitive["radius_m"])
    elif ptype == "cone":
        shape = _cone_between(start, end, primitive["radius1_m"], primitive["radius2_m"])
    elif ptype == "elbow_sweep":
        bend_radius = primitive.get("arc_bend_radius_m", primitive.get("arc_radius_m", 0.0))
        tube_radius = primitive.get("arc_tube_radius_m", bend_radius)
        shape = _make_elbow_sweep(
            primitive["arc_start_m"],
            primitive["arc_end_m"],
            primitive["arc_center_m"],
            bend_radius,
            tube_radius,
        )

    if shape is None:
        continue

    obj = doc.addObject("Part::Feature", _safe_name(primitive.get("name", "primitive"), used_names))
    obj.Shape = shape
    created.append(obj)

if created:
    compound_shape = Part.makeCompound([obj.Shape for obj in created])
    compound_obj = doc.addObject("Part::Feature", "manifold_primitives_" + BUILD_ID)
    compound_obj.Shape = compound_shape

union_obj = None
patch_objects = []
patch_shapes = {{}}
if created:
    fused_shape = created[0].Shape.copy()
    for obj in created[1:]:
        fused_shape = fused_shape.fuse(obj.Shape)
    fused_shape = fused_shape.removeSplitter()

    union_obj = doc.addObject("Part::Feature", "manifold_union_" + BUILD_ID)
    union_obj.Shape = fused_shape

    patch_faces, wall_faces = _extract_patch_faces(fused_shape)
    for patch_name in ["inlet", "outlet_33", "outlet_43", "outlet_53"]:
        face = patch_faces.get(patch_name)
        if face is None:
            continue
        patch_shape = Part.Compound([face.copy()])
        patch_shapes[patch_name] = patch_shape
        patch_obj = doc.addObject("Part::Feature", _safe_name(patch_name, used_names))
        patch_obj.Shape = patch_shape
        patch_objects.append(patch_obj)

    if wall_faces:
        wall_shape = Part.Compound([face.copy() for face in wall_faces])
        patch_shapes["wall"] = wall_shape
        wall_obj = doc.addObject("Part::Feature", _safe_name("wall", used_names))
        wall_obj.Shape = wall_shape
        patch_objects.append(wall_obj)

doc.recompute()

script_path = globals().get("__file__", "")
if script_path:
    out_dir = os.path.join(os.path.dirname(os.path.abspath(script_path)), "geometry")
else:
    out_dir = os.path.join(os.getcwd(), "geometry")

os.makedirs(out_dir, exist_ok=True)

fcstd_path = os.path.join(out_dir, BASE_NAME + ".FCStd")
step_path = os.path.join(out_dir, BASE_NAME + ".step")

# Also write build-stamped copies so you can visually identify exact builds.
fcstd_stamped_path = os.path.join(out_dir, BASE_NAME + "_" + BUILD_ID + ".FCStd")
step_stamped_path = os.path.join(out_dir, BASE_NAME + "_" + BUILD_ID + ".step")

if created:
    start_time = time.time()
    export_shapes = [union_obj] if union_obj is not None else created
    Part.export(export_shapes, step_path)
    Part.export(export_shapes, step_stamped_path)
    print("[manifold] STEP export done in %.2fs" % (time.time() - start_time))

    # Phase 4 artifacts: extracted boundary patch faces as separate objects.
    if patch_objects:
        start_time = time.time()
        patch_step_path = os.path.join(out_dir, BASE_NAME + "_patches.step")
        patch_step_stamped_path = os.path.join(out_dir, BASE_NAME + "_patches_" + BUILD_ID + ".step")
        Part.export(patch_objects, patch_step_path)
        Part.export(patch_objects, patch_step_stamped_path)
        print("[manifold] patch STEP export done in %.2fs" % (time.time() - start_time))

    # Phase 5 artifacts: ASCII STL per patch + multi-solid concatenated STL.
    if patch_shapes:
        start_time = time.time()
        print("[manifold] ASCII STL deflection=%.6f" % STL_DEFLECTION)
        patch_names = ["inlet", "wall", "outlet_33", "outlet_43", "outlet_53"]
        patch_files = []
        patch_stamped_files = []
        for patch_name in patch_names:
            patch_shape = patch_shapes.get(patch_name)
            if patch_shape is None:
                continue
            patch_path = os.path.join(out_dir, patch_name + ".stl")
            patch_stamped_path = os.path.join(out_dir, patch_name + "_" + BUILD_ID + ".stl")
            triangle_count = _write_ascii_stl(patch_shape, patch_path, patch_name)
            _write_ascii_stl(patch_shape, patch_stamped_path, patch_name)
            print("[manifold] patch %s triangles=%d" % (patch_name, triangle_count))
            patch_files.append(patch_path)
            patch_stamped_files.append(patch_stamped_path)

        manifold_ascii_path = os.path.join(out_dir, BASE_NAME + ".stl")
        manifold_ascii_stamped_path = os.path.join(out_dir, BASE_NAME + "_" + BUILD_ID + ".stl")
        _concat_ascii_stls(manifold_ascii_path, patch_files)
        _concat_ascii_stls(manifold_ascii_stamped_path, patch_stamped_files)
        print("[manifold] ASCII STL export+concat done in %.2fs" % (time.time() - start_time))

if SAVE_FCSTD:
    start_time = time.time()
    doc.saveAs(fcstd_path)
    doc.saveAs(fcstd_stamped_path)
    print("[manifold] FCStd save done in %.2fs" % (time.time() - start_time))
else:
    print("[manifold] FCStd save skipped (set MANIFOLD_SAVE_FCSTD=1 to enable)")
'''
    macro_path.write_text(macro_text, encoding="utf-8")


def build_model(csv_path: Path, root_node: str = DEFAULT_ROOT_NODE, short_segment_threshold_m: float = DEFAULT_SHORT_SEGMENT_THRESHOLD_M) -> dict[str, Any]:
    df = load_pipe_system(csv_path)
    graph = build_graph(df, root_node=root_node)
    geometry = build_geometry(df, graph, short_segment_threshold_m=short_segment_threshold_m)

    nodes = [
        asdict(
            NodeCoordinate(
                node=node_id,
                label=graph["node_labels"].get(node_id),
                x_m=float(coord[0]),
                y_m=float(coord[1]),
                z_m=float(coord[2]),
            )
        )
        for node_id, coord in sorted(graph["coords"].items(), key=lambda item: int(item[0]))
    ]

    return {
        "source_csv": str(csv_path),
        "root_node": root_node,
        "nodes": nodes,
        "segments": [
            {
                key: list(value) if isinstance(value, tuple) else value
                for key, value in segment.items()
            }
            for segment in geometry["segments"]
        ],
        "elbow_nodes": {
            node_id: {key: list(value) if isinstance(value, tuple) else value for key, value in elbow.items()}
            for node_id, elbow in geometry["elbow_nodes"].items()
        },
    }


def print_summary(model: dict[str, Any]) -> None:
    print(f"Loaded {len(model['segments'])} elements and {len(model['nodes'])} nodes from {model['source_csv']}")
    print("\nNodes:")
    for node in model["nodes"]:
        print(f"Node {node['node']}: ({node['x_m']:.6f}, {node['y_m']:.6f}, {node['z_m']:.6f})")

    print("\nElbows:")
    for node_id in sorted(model["elbow_nodes"], key=lambda value: int(value)):
        elbow = model["elbow_nodes"][node_id]
        print(
            f"Node {node_id} via element {elbow['element']}: setback={elbow['setback_m']:.6f} m, "
            f"tangent_in={tuple(elbow['tangent_in_m'])}, tangent_out={tuple(elbow['tangent_out_m'])}"
        )

    print("\nReducers:")
    for segment in model["segments"]:
        if segment["kind"] != "reducer":
            continue
        status = "ok" if segment["reducer_length_ok"] else "mismatch"
        print(
            f"Element {segment['element']}: expected={segment['reducer_expected_length_m']:.6f} m, "
            f"actual={segment['length_m']:.6f} m, status={status}"
        )

    skipped = [str(segment["element"]) for segment in model["segments"] if segment["skip_for_cylinder"]]
    print("\nSkipped short segments: " + (", ".join(skipped) if skipped else "none"))


def print_elbow_debug(phase3_model: dict[str, Any]) -> None:
    elbows = [primitive for primitive in phase3_model["primitives"] if primitive.get("type") == "elbow_sweep"]
    if not elbows:
        print("\nElbow debug: no elbow primitives found")
        return

    print("\nElbow debug:")
    for elbow in elbows:
        name = str(elbow["name"])
        corner = cast(tuple[float, float, float], tuple(float(v) for v in elbow["corner_m"]))
        center = cast(tuple[float, float, float], tuple(float(v) for v in elbow["arc_center_m"]))
        start = cast(tuple[float, float, float], tuple(float(v) for v in elbow["arc_start_m"]))
        end = cast(tuple[float, float, float], tuple(float(v) for v in elbow["arc_end_m"]))
        bend_radius = float(elbow.get("arc_bend_radius_m", elbow.get("arc_radius_m", 0.0)))
        tube_radius = float(elbow.get("arc_tube_radius_m", bend_radius))
        incoming = cast(tuple[float, float, float], tuple(float(v) for v in elbow["incoming_direction"]))
        outgoing = cast(tuple[float, float, float], tuple(float(v) for v in elbow["outgoing_direction"]))

        rs = vector_length(vector_sub(start, center))
        re = vector_length(vector_sub(end, center))
        chord = vector_length(vector_sub(end, start))

        print(f"- {name}")
        print(f"  corner_m={corner}")
        print(f"  center_m={center}")
        print(f"  start_m={start}")
        print(f"  end_m={end}")
        print(f"  incoming_direction={incoming}")
        print(f"  outgoing_direction={outgoing}")
        print(
            f"  bend_radius_m={bend_radius:.9f}, tube_radius_m={tube_radius:.9f}, "
            f"|start-center|={rs:.9f}, |end-center|={re:.9f}, chord={chord:.9f}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Build phase 1 to phase 3 manifold geometry artifacts.")
    parser.add_argument("--csv", type=Path, default=Path("pipe-system.csv"), help="Input pipe-system CSV")
    parser.add_argument("--root-node", default=DEFAULT_ROOT_NODE, help="Root node used as the coordinate origin")
    parser.add_argument(
        "--short-threshold",
        type=float,
        default=DEFAULT_SHORT_SEGMENT_THRESHOLD_M,
        help="Dummy segment cutoff in meters",
    )
    parser.add_argument("--json", type=Path, help="Optional JSON output path")
    parser.add_argument("--phase3-json", type=Path, help="Optional JSON output path for primitive definitions")
    parser.add_argument("--phase3-freecad-macro", type=Path, help="Optional FreeCAD macro output path for primitives")
    parser.add_argument("--freecad-doc-name", default="Manifold", help="Document name used inside generated FreeCAD macro")
    parser.add_argument("--debug-elbow", action="store_true", help="Print detailed elbow arc debug data")
    parser.add_argument("--summary", action="store_true", help="Print a human-readable summary")
    args = parser.parse_args()

    build_id = compute_build_id(args.csv)
    model = build_model(args.csv, root_node=args.root_node, short_segment_threshold_m=args.short_threshold)
    phase3_model = build_phase3_primitives(model, build_id=build_id)

    if args.json:
        args.json.write_text(json.dumps(model, indent=2), encoding="utf-8")

    if args.phase3_json:
        args.phase3_json.write_text(json.dumps(phase3_model, indent=2), encoding="utf-8")

    if args.phase3_freecad_macro:
        write_phase3_freecad_macro(phase3_model, args.phase3_freecad_macro, document_name=args.freecad_doc_name)

    if args.summary or not args.json:
        print_summary(model)
        print(f"\nBuild ID: {build_id}")
        print(
            "\nPhase 3 primitives: "
            f"{phase3_model['counts']['primitives']} total "
            f"(pipes: {phase3_model['counts']['pipes']}, "
            f"elbows: {phase3_model['counts']['elbows']}, reducers: {phase3_model['counts']['reducers']})"
        )

    if args.debug_elbow:
        print_elbow_debug(phase3_model)


if __name__ == "__main__":
    main()