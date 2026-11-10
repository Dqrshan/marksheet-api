/**
 * Fetch the courses of one semester and compute an SGPA from them.
 *
 *   node examples/javascript.mjs
 *
 * No dependencies, no key, no token.
 */

const BASE = "https://vtu.drshn.tech/api";

const GRADE_POINTS = [
  [90, 10],
  [80, 9],
  [70, 8],
  [60, 7],
  [55, 6],
  [50, 5],
  [40, 4],
  [0, 0],
];

const pointsFor = (marks) => GRADE_POINTS.find(([min]) => marks >= min)[1];

const scheme = "2022";
const branch = "cs";
const semester = "3";

// The marks from a marks card, keyed by course code.
const marks = {
  BCS301: 85,
  BCS302: 78,
  BCS303: 92,
  BCS304: 74,
  BCS306X: 81,
  BCS358X: 88,
  BCSL305: 95,
  BSCK307: 90,
};

const response = await fetch(
  `${BASE}/schemes/${scheme}/branches/${branch}/semesters/${semester}`,
);
const { courses } = await response.json();

let weighted = 0;
let credits = 0;

for (const course of courses) {
  const mark = marks[course.code];
  if (mark === undefined || course.credits <= 0) continue;
  weighted += course.credits * pointsFor(mark);
  credits += course.credits;
  console.log(
    `${course.code}  ${String(course.credits).padStart(2)} cr  ${course.title}`,
  );
}

const sgpa = credits === 0 ? 0 : weighted / credits;
console.log(`\ncredits  ${credits}`);
console.log(`SGPA     ${sgpa.toFixed(2)}`);
console.log(`percent  ${(sgpa * 10).toFixed(2)}`);
