type Polynomial = {
	readonly coefficients: readonly number[];
};

function evaluate(polynomial: Polynomial, x: number): number {
	return polynomial.coefficients.reduceRight(
		(value, coefficient) => value * x + coefficient,
		0,
	);
}

const polynomial: Polynomial = { coefficients: [1, 0, 1] };
if (evaluate(polynomial, 2) !== 5) {
	throw new Error("TypeScript stripping example failed");
}

console.log("Node.js TypeScript stripping passed");
