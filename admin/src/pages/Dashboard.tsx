import { Link } from "react-router-dom";
import { CalendarCheck, Coins, Users, Clock3 } from "lucide-react";
import { AppShell } from "@/components/layout/AppShell";
import { StatCard } from "@/components/ui/StatCard";
import { StatusChip } from "@/components/ui/StatusChip";
import { useBookings, useCustomers } from "@/data/store";
import { formatRand } from "@/lib/money";
import { isSameDay, formatDateLong } from "@/lib/time";

export default function Dashboard() {
  const bookings = useBookings();
  const customers = useCustomers();

  const today = new Date();
  const todayBookings = bookings
    .filter((b) => isSameDay(b.date, today))
    .sort((a, b) => a.startTime.localeCompare(b.startTime));

  const weekStart = new Date(today);
  weekStart.setDate(today.getDate() - 6);
  const last7 = bookings.filter(
    (b) => b.date >= weekStart && b.status === "completed"
  );
  const revenueCents = last7.reduce((s, b) => s + b.priceCents, 0);

  const pendingCount = bookings.filter(
    (b) => b.status === "pendingPayment"
  ).length;

  return (
    <AppShell title="Dashboard" subtitle={formatDateLong(today)}>
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3 sm:gap-4 mb-6 md:mb-8">
        <StatCard
          eyebrow="Today"
          value={todayBookings.length}
          hint={`${todayBookings.filter((b) => b.status === "confirmed").length} confirmed`}
          icon={<CalendarCheck size={18} />}
          accent
        />
        <StatCard
          eyebrow="Revenue · 7d"
          value={formatRand(revenueCents)}
          hint={`${last7.length} completed jobs`}
          icon={<Coins size={18} />}
        />
        <StatCard
          eyebrow="Customers"
          value={customers.length}
          hint="total on platform"
          icon={<Users size={18} />}
        />
        <StatCard
          eyebrow="Pending payment"
          value={pendingCount}
          hint="awaiting customer"
          icon={<Clock3 size={18} />}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <section className="lg:col-span-2 card p-0 overflow-hidden">
          <header className="px-4 sm:px-5 py-4 border-b border-hair flex items-center justify-between gap-3">
            <div className="min-w-0">
              <div className="eyebrow">Today&apos;s schedule</div>
              <div className="serif text-lg sm:text-xl mt-0.5 truncate">
                {todayBookings.length === 0
                  ? "No jobs booked"
                  : `${todayBookings.length} jobs lined up`}
              </div>
            </div>
            <Link
              to="/schedule"
              className="text-sm font-semibold text-accent hover:underline whitespace-nowrap shrink-0"
            >
              Open schedule →
            </Link>
          </header>

          {todayBookings.length === 0 ? (
            <div className="p-8 sm:p-10 text-center text-sm text-ink-3">
              A quiet day — no valets booked.
            </div>
          ) : (
            <ul className="divide-y divide-hair">
              {todayBookings.map((b) => (
                <li
                  key={b.id}
                  className="px-4 sm:px-5 py-3 sm:py-4 flex items-center gap-3 sm:gap-4 hover:bg-surface-alt/60 transition-colors"
                >
                  <div className="w-12 sm:w-14 text-center shrink-0">
                    <div className="serif text-xl sm:text-2xl leading-none tabular">
                      {b.startTime}
                    </div>
                    <div className="text-[10px] text-ink-3 mt-1">
                      {b.serviceDurationMinutes} min
                    </div>
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="font-semibold truncate">
                      {b.serviceName}
                    </div>
                    <div className="text-sm text-ink-3 truncate">
                      {b.customerName} · {b.address.suburb}
                    </div>
                  </div>
                  <div className="text-right shrink-0">
                    <div className="tabular font-semibold text-sm sm:text-base">
                      {formatRand(b.priceCents)}
                    </div>
                    <div className="mt-1 hidden sm:block">
                      <StatusChip status={b.status} />
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>

        <section className="card p-4 sm:p-5">
          <div className="eyebrow">Live activity</div>
          <div className="serif text-lg sm:text-xl mt-0.5 mb-4">
            Recent bookings
          </div>
          <ul className="space-y-3">
            {bookings
              .slice()
              .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
              .slice(0, 6)
              .map((b) => (
                <li key={b.id} className="flex items-center gap-3 text-sm">
                  <div className="h-8 w-8 rounded-full bg-surface-alt flex items-center justify-center text-xs font-semibold shrink-0">
                    {b.customerName
                      .split(" ")
                      .map((n) => n[0])
                      .slice(0, 2)
                      .join("")}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="truncate">
                      <span className="font-semibold">{b.customerName}</span>
                      <span className="text-ink-3"> booked </span>
                      <span>{b.serviceName}</span>
                    </div>
                    <div className="text-xs text-ink-3">
                      {b.date.toLocaleDateString("en-ZA", {
                        day: "numeric",
                        month: "short",
                      })}{" "}
                      · {b.startTime}
                    </div>
                  </div>
                </li>
              ))}
          </ul>
        </section>
      </div>
    </AppShell>
  );
}
