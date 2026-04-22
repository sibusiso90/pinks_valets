import { useMemo, useState } from "react";
import clsx from "clsx";
import { Link } from "react-router-dom";
import { Search } from "lucide-react";
import { AppShell } from "@/components/layout/AppShell";
import { StatusChip } from "@/components/ui/StatusChip";
import { useBookings } from "@/data/store";
import { formatRand } from "@/lib/money";
import { formatDateShort } from "@/lib/time";
import { STATUS_LABEL } from "@/data/status";
import type { BookingStatus } from "@/data/types";

type Tab = "upcoming" | "today" | "history" | "all";

export default function Bookings() {
  const bookings = useBookings();
  const [tab, setTab] = useState<Tab>("upcoming");
  const [statusFilter, setStatusFilter] = useState<BookingStatus | "all">(
    "all"
  );
  const [q, setQ] = useState("");

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const filtered = useMemo(() => {
    const needle = q.trim().toLowerCase();
    return bookings
      .filter((b) => {
        if (tab === "today") {
          return b.date.getTime() === today.getTime();
        }
        if (tab === "upcoming") {
          return b.date.getTime() >= today.getTime();
        }
        if (tab === "history") {
          return b.date.getTime() < today.getTime();
        }
        return true;
      })
      .filter((b) => (statusFilter === "all" ? true : b.status === statusFilter))
      .filter((b) =>
        needle === ""
          ? true
          : b.id.toLowerCase().includes(needle) ||
            b.customerName.toLowerCase().includes(needle) ||
            b.serviceName.toLowerCase().includes(needle) ||
            b.address.suburb.toLowerCase().includes(needle)
      )
      .sort((a, b) => {
        const d = a.date.getTime() - b.date.getTime();
        if (d !== 0) return d;
        return a.startTime.localeCompare(b.startTime);
      });
  }, [bookings, tab, statusFilter, q, today]);

  const tabs: { id: Tab; label: string; count: number }[] = [
    {
      id: "upcoming",
      label: "Upcoming",
      count: bookings.filter((b) => b.date.getTime() >= today.getTime()).length,
    },
    {
      id: "today",
      label: "Today",
      count: bookings.filter((b) => b.date.getTime() === today.getTime()).length,
    },
    {
      id: "history",
      label: "History",
      count: bookings.filter((b) => b.date.getTime() < today.getTime()).length,
    },
    { id: "all", label: "All", count: bookings.length },
  ];

  const statuses: (BookingStatus | "all")[] = [
    "all",
    "pendingPayment",
    "confirmed",
    "inProgress",
    "completed",
    "cancelledByCustomer",
    "noShow",
  ];

  return (
    <AppShell title="Bookings" subtitle="Every wash, old and upcoming">
      <div className="flex flex-col gap-3 mb-4">
        <div className="flex items-center gap-1 bg-surface-alt p-1 rounded-md overflow-x-auto scrollbar-thin -mx-4 sm:mx-0 px-4 sm:px-1">
          {tabs.map((t) => (
            <button
              key={t.id}
              onClick={() => setTab(t.id)}
              className={clsx(
                "px-3 h-9 sm:h-8 rounded text-sm font-semibold flex items-center gap-2 whitespace-nowrap transition-colors",
                "focus:outline-none focus-visible:ring-2 focus-visible:ring-accent",
                tab === t.id
                  ? "bg-surface text-ink shadow-sm"
                  : "text-ink-3 hover:text-ink"
              )}
            >
              {t.label}
              <span
                className={clsx(
                  "tabular text-[10px] px-1.5 py-0.5 rounded-full",
                  tab === t.id
                    ? "bg-accent-soft text-accent"
                    : "bg-hair text-ink-3"
                )}
              >
                {t.count}
              </span>
            </button>
          ))}
        </div>

        <div className="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-3">
          <div className="relative flex-1 min-w-0">
            <Search
              size={16}
              className="absolute left-3 top-1/2 -translate-y-1/2 text-ink-3 pointer-events-none"
            />
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search ref, customer, service, area…"
              className="input pl-9 w-full sm:max-w-sm"
              aria-label="Search bookings"
            />
          </div>
          <select
            value={statusFilter}
            onChange={(e) =>
              setStatusFilter(e.target.value as BookingStatus | "all")
            }
            className="input sm:w-56"
            aria-label="Filter by status"
          >
            {statuses.map((s) => (
              <option key={s} value={s}>
                {s === "all" ? "All statuses" : STATUS_LABEL[s as BookingStatus]}
              </option>
            ))}
          </select>
        </div>
      </div>

      {filtered.length === 0 ? (
        <div className="card p-10 text-center text-sm text-ink-3">
          No bookings match this view.
        </div>
      ) : (
        <>
          {/* Mobile card list */}
          <ul className="md:hidden space-y-2.5">
            {filtered.map((b) => (
              <li key={b.id}>
                <Link
                  to={`/bookings/${b.id}`}
                  className="card card-hover p-4 flex flex-col gap-3 active:bg-surface-alt/60"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="font-semibold truncate">
                        {b.customerName}
                      </div>
                      <div className="text-sm text-ink-3 truncate">
                        {b.serviceName} · {b.serviceDurationMinutes} min
                      </div>
                    </div>
                    <StatusChip status={b.status} />
                  </div>
                  <div className="flex items-center justify-between gap-3 text-xs text-ink-3">
                    <div className="tabular">
                      {formatDateShort(b.date)} · {b.startTime}
                    </div>
                    <div className="truncate">{b.address.suburb}</div>
                    <div className="tabular font-semibold text-ink">
                      {formatRand(b.priceCents)}
                    </div>
                  </div>
                  <div className="tabular font-mono text-[10px] text-ink-3">
                    {b.id}
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
                    <th className="px-4 py-3 font-semibold">Ref</th>
                    <th className="px-4 py-3 font-semibold">Customer</th>
                    <th className="px-4 py-3 font-semibold">Service</th>
                    <th className="px-4 py-3 font-semibold">When</th>
                    <th className="px-4 py-3 font-semibold">Area</th>
                    <th className="px-4 py-3 font-semibold text-right">
                      Amount
                    </th>
                    <th className="px-4 py-3 font-semibold">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-hair">
                  {filtered.map((b) => (
                    <tr
                      key={b.id}
                      className="hover:bg-surface-alt/60 transition-colors"
                    >
                      <td className="px-4 py-3 tabular font-mono text-xs">
                        <Link
                          to={`/bookings/${b.id}`}
                          className="hover:underline text-ink"
                        >
                          {b.id}
                        </Link>
                      </td>
                      <td className="px-4 py-3">
                        <div className="font-medium">{b.customerName}</div>
                        <div className="text-xs text-ink-3">
                          {b.customerPhone}
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        <div className="font-medium">{b.serviceName}</div>
                        <div className="text-xs text-ink-3">
                          {b.serviceDurationMinutes} min
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        <div className="font-medium tabular">
                          {formatDateShort(b.date)}
                        </div>
                        <div className="text-xs text-ink-3 tabular">
                          {b.startTime}
                        </div>
                      </td>
                      <td className="px-4 py-3">{b.address.suburb}</td>
                      <td className="px-4 py-3 text-right tabular font-semibold">
                        {formatRand(b.priceCents)}
                      </td>
                      <td className="px-4 py-3">
                        <StatusChip status={b.status} />
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
