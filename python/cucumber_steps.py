"""Find pytest-bdd step definitions using Python's syntax tree."""

from __future__ import annotations

import ast
import json
import subprocess
import sys
from pathlib import Path
from typing import TypedDict


class Definition(TypedDict):
    filename: str
    line: int
    line_start: int
    line_end: int
    parser: str
    pattern: str


def call_name(call: ast.Call) -> str | None:
    if isinstance(call.func, ast.Name):
        return call.func.id
    if isinstance(call.func, ast.Attribute):
        return call.func.attr
    return None


def parser_pattern(value: ast.expr) -> tuple[str, str] | None:
    if isinstance(value, ast.Constant) and isinstance(value.value, str):
        return value.value, "literal"
    if not isinstance(value, ast.Call) or not value.args:
        return None

    parser = call_name(value)
    pattern = value.args[0]
    if parser not in {"parse", "cfparse", "re"}:
        return None
    if not isinstance(pattern, ast.Constant) or not isinstance(pattern.value, str):
        return None

    return pattern.value, "re" if parser == "re" else "parse"


def definitions_in(filename: Path) -> list[Definition]:
    try:
        tree = ast.parse(filename.read_text())
    except (OSError, SyntaxError, UnicodeDecodeError):
        return []

    definitions: list[Definition] = []
    for node in ast.walk(tree):
        if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue

        line_start = min([node.lineno, *(item.lineno for item in node.decorator_list)])
        for decorator in node.decorator_list:
            if not isinstance(decorator, ast.Call) or call_name(decorator) not in {
                "given",
                "when",
                "then",
                "step",
            }:
                continue
            if not decorator.args:
                continue

            match = parser_pattern(decorator.args[0])
            if not match:
                continue

            pattern, parser = match
            definitions.append(
                {
                    "filename": str(filename),
                    "line": decorator.lineno,
                    "line_start": line_start,
                    "line_end": node.end_lineno or node.lineno,
                    "parser": parser,
                    "pattern": pattern,
                }
            )

    return definitions


def python_files(root: Path) -> list[Path]:
    result = subprocess.run(
        [
            "rg",
            "--files-with-matches",
            "--glob",
            "*.py",
            r"@(given|when|then|step)\b",
            ".",
        ],
        cwd=root,
        capture_output=True,
        check=False,
        text=True,
    )
    return [root / filename for filename in result.stdout.splitlines()]


def main() -> None:
    root = Path(sys.argv[1])
    definitions: list[Definition] = []
    for filename in python_files(root):
        definitions.extend(definitions_in(filename))

    print(json.dumps(definitions))


if __name__ == "__main__":
    main()
