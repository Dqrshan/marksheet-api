"""Fetch the courses of one semester and compute an SGPA from them.

    python3 examples/python.py

Uses only the standard library, so there is nothing to install.
"""

import json
import urllib.request

BASE = "https://vtu.drshn.tech/api"

GRADE_POINTS = [
    (90, 10),
    (80, 9),
    (70, 8),
    (60, 7),
    (55, 6),
    (50, 5),
    (40, 4),
    (0, 0),
]


def points_for(marks: float) -> int:
    for minimum, points in GRADE_POINTS:
        if marks >= minimum:
            return points
    return 0


def get(path: str) -> dict:
    with urllib.request.urlopen(f"{BASE}{path}") as response:
        return json.load(response)


scheme = "2022"
branch = "cs"
semester = "3"

# The marks from a marks card, keyed by course code.
marks = {
    "BCS301": 85,
    "BCS302": 78,
    "BCS303": 92,
    "BCS304": 74,
    "BCS306X": 81,
    "BCS358X": 88,
    "BCSL305": 95,
    "BSCK307": 90,
}

payload = get(f"/schemes/{scheme}/branches/{branch}/semesters/{semester}")

weighted = 0.0
credits = 0

for course in payload["courses"]:
    mark = marks.get(course["code"])
    if mark is None or course["credits"] <= 0:
        continue
    weighted += course["credits"] * points_for(mark)
    credits += course["credits"]
    print(f"{course['code']}  {course['credits']:>2} cr  {course['title']}")

sgpa = weighted / credits if credits else 0.0
print(f"\ncredits  {credits}")
print(f"SGPA     {sgpa:.2f}")
print(f"percent  {sgpa * 10:.2f}")
