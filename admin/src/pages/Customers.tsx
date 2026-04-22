import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { Search } from "lucide-react";
import { AppShell } from "@/components/layout/AppShell";
import { useBookings, useCustomers } from "@/data/store";
import { formatRand } from "@/lib/money";

export default function Customers() {
  const customers = useCustomers();
  const bookings = useBookings();
  const [q, setQ] = useState("");

  const enriched = useMemo(() => {
    return customers.map((c) => {
      const theirs = bookings.filter((b) => b.customerId === c.id);
      const lifetimeCents = theirs
        .filter((b) => b.status === "completed")
        .reduce((s, b) => s + b.priceCents, 0);
      const last = theirs
        .slice()
        .sort((a, b) => b.date.getTime() - a.date.getTime())[0];
      return {
        ...c,
        bookingsCount: theirs.length,
        lifetimeCents,
        lastActivity: last?.date,
      };
    });
  }, [customers, bookings]);

  const filtered = enriched.filter((c) => {
    const n = q.trim().toLowerCase();
    if (n === "") return true;
    return (
      c.displayName.toLowerCase().includes(n) ||
      c.phone.toLowerCase().includes(n) ||
      c.email.toLowerCase().includes(n)
    );
  });

  return (
    <AppShell title="Customers" subtitle="Everyone who has washed with Pink's">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
        <div className="relative flex-1 sm:max-w-md">
          <Search
            size={16}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-ink-3 pointer-events-none"
          />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search name, phone, email…"
            className="input pl-9 w-full"
            aria-label="Search customers"
          />
        </div>
        <div className="text-sm text-ink-3 tabular">
          {filtered.length} of {customers.length}
        </div>
      </div>

      {filtered.length === 0 ? (
        <div className="card p-10 text-center text-sm text-ink-3">
          No customers match that search.
        </div>
      ) : (
        <>
          {/* Mobile card list */}
          <ul className="md:hidden space-y-2.5">
            {filtered.map((c) => (
              <li key={c.id}>
                <Link
                  to={`/customers/${c.id}`}
                  className="card card-hover p-4 flex items-center gap-3 active:bg-surface-alt/60"
                >
                  <div className="h-10 w-10 rounded-full bg-surface-alt text-ink-2 flex items-center justify-center text-sm font-semibold shrink-0">
                    {c.displayName
                      .split(" ")
                      .map((n) => n[0])
                      .slice(0, 2)
                      .join("")}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="font-semibold truncate">
                      {c.displayName}
                    </div>
                    <div className="text-xs text-ink-3 truncate">
                      {c.phone} · {c.email}
                    </div>
                  </div>
                  <div className="text-right shrink-0">
                    <div className="tabular font-semibold text-sm">
                      {formatRand(c.lifetimeCents)}
                    </div>
                    <div className="text-xs text-ink-3 tabular">
                      {c.bookingsCount} booking
                      {c.bookingsCount === 1 ? "" : "s"}
                    </div>
                  </div>
                </Link>
              </li>
            ))}
          </ul>

          {/* Desktop table */}
          <div className="hidden md:block card overflow-hidden">
            <div className="table-wrap scrollbar-thin">
              <table>
                <thead className="bg-surface-alt text-ink-3">
                  <tr className="text-left">
                    <th className="px-4 py-3 font-semibold">Name</th>
                    <th className="px-4 py-3 font-semibold">Contact</th>
                    <th className="px-4 py-3 font-semibold text-right">
                      Bookings
                    </th>
                    <th className="px-4 py-3 font-semibold text-right">
                      Lifetime value
                    </th>
                    <th className="px-4 py-3 font-semibold">Last activity</th>
                    <th className="px-4 py-3 font-semibold">Joined</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-hair">
                  {filtered.map((c) => (
                    <tr
                      key={c.id}
                      className="hover:bg-surface-alt/60 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <Link
                          to={`/customers/${c.id}`}
                          className="font-semibold hover:underline"
                        >
                          {c.displayName}
                        </Link>
                      </td>
                      <td className="px-4 py-3 text-xs">
                        <div>{c.phone}</div>
                        <div className="text-ink-3">{c.email}</div>
                      </td>
                      <td className="px-4 py-3 tabular text-right">
                        {c.bookingsCount}
                      </td>
                      <td className="px-4 py-3 tabular text-right font-semibold">
                        {formatRand(c.lifetimeCents)}
                      </td>
                      <td className="px-4 py-3 tabular text-xs text-ink-3">
                        {c.lastActivity
                          ? c.lastActivity.toLocaleDateString("en-ZA", {
                              day: "numeric",
                              month: "short",
                              year: "numeric",
                            })
                          : "—"}
                      </td>
                      <td className="px-4 py-3 tabular text-xs text-ink-3">
                        {c.createdAt.toLocaleDateString("en-ZA", {
                          day: "numeric",
                          month: "short",
                          year: "numeric",
                        })}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </AppShell>
  );
}
