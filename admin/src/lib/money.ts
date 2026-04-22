// Format cents as South African Rand using a thin space separator, e.g. 125000 -> "R1 250".
// Matches the Flutter mobile app's formatRand so both surfaces render money identically.
export function formatRand(cents: number): string {
  const rands = Math.round(cents / 100);
  const sign = rands < 0 ? "-" : "";
  const abs = Math.abs(rands).toString();
  const withSeparator = abs.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
  return `${sign}R${withSeparator}`;
}

export function formatRandWithCents(cents: number): string {
  const sign = cents < 0 ? "-" : "";
  const abs = Math.abs(cents);
  const rands = Math.floor(abs / 100).toString();
  const frac = (abs % 100).toString().padStart(2, "0");
  const withSeparator = rands.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
  return `${sign}R${withSeparator}.${frac}`;
}
