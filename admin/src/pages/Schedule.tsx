import { useMemo, useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import clsx from "clsx";
import { Link } from "react-router-dom";
import { AppShell } from "@/components/layout/AppShell";
import { StatusChip } from "@/components/ui/StatusChip";
import { useBookings, useSchedules } from "@/data/store";
import { addDays, isSameDay, parseMinutes, startOfWeek } from "@/lib/time";
import { formatRand } from "@/lib/money";

const HOUR_HEIGHT = 56; // px per hour in the timeline

export default function Schedule() {
  const bookings = useBookings();
  const schedules = useSchedules();
  const [weekAnchor, setWeekAnchor] = useState<Date>(() =>
    startOfWeek(new Date())
  );
  const [focusedDay, setFocusedDay] = useState<Date>(() => {
    const t = new Date();
    t.setHours(0, 0, 0, 0);
    return t;
  });

  const days = useMemo(
    () => Array.from({ length: 7 }, (_, i) => addDays(weekAnchor, i)),
    [weekAnchor]
  );

  // Keep the single-day mobile focus inside the visible week.
  const activeDay = useMemo(() => {
    const inWeek = days.find((d) => isSameDay(d, focusedDay));
    return inWeek ?? days[0];
  }, [days, focusedDay]);

  // Timeline window: earliest open to latest close across days shown.
  const { dayStartMin, dayEndMin } = useMemo(() => {
    let start = 7 * 60;
    let end = 18 * 60;
    for (const d of days) {
      const dow = ((d.getDay() + 6) % 7) + 1; // 1=Mon..7=Sun
      const sch = schedules.find((s) => s.dayOfWeek === dow);
      if (!sch || !sch.isOpen) continue;
      start = Math.min(start, parseMinutes(sch.openTime));
      end = Math.max(end, parseMinutes(sch.closeTime));
    }
    return { dayStartMin: start, dayEndMin: end };
  }, [days, schedules]);

  const hours = Array.from(
    { length: Math.ceil((dayEndMin - dayStartMin) / 60) + 1 },
    (_, i) => Math.floor(dayStartMin / 60) + i
  );

  const activeDow = ((activeDay.getDay() + 6) % 7) + 1;
  const activeSchedule = schedules.find((s) => s.dayOfWeek === activeDow);
  const activeDayBookings = bookings
    .filter((b) => isSameDay(b.date, activeDay))
    .sort((a, b) => a.startTime.localeCompare(b.startTime));

  return (
    <AppShell title="Schedule" subtitle="Week view, all valets in sight">
      <div className="flex flex-col sm:flex-row sm:items-center gap-3 mb-4">
        <div className="flex items-center gap-2">
          <button
            className="btn-soft h-9 px-3"
            onClick={() => setWeekAnchor((d) => addDays(d, -7))}
            aria-label="Previous week"
          >
            <ChevronLeft size={16} />
          </button>
          <button
            className="btn-soft h-9"
            onClick={() => {
              const t = new Date();
              setWeekAnchor(startOfWeek(t));
              t.setHours(0, 0, 0, 0);
              setFocusedDay(t);
            }}
          >
            This week
          </button>
          <button
            className="btn-soft h-9 px-3"
            onClick={() => setWeekAnchor((d) => addDays(d, 7))}
            aria-label="Next week"
          >
            <ChevronRight size={16} />
          </button>
        </div>
        <div className="sm:ml-2 serif text-lg sm:text-xl">
          {weekAnchor.toLocaleDateString("en-ZA", {
            day: "numeric",
            month: "short",
          })}{" "}
          –{" "}
          {addDays(weekAnchor, 6).toLocaleDateString("en-ZA", {
            day: "numeric",
            month: "short",
            year: "numeric",
          })}
        </div>
      </div>

      {/* Mobile & tablet (< lg): day chips + stacked list */}
      <div className="lg:hidden">
        <div className="grid grid-cols-7 gap-1 mb-3">
          {days.map((d) => {
            const isActive = isSameDay(d, activeDay);
            const isToday = isSameDay(d, new Date());
            const dayCount = bookings.filter((b) =>
              isSameDay(b.date, d)
            ).length;
            return (
              <button
                key={d.toISOString()}
                onClick={() => setFocusedDay(d)}
                className={clsx(
                  "flex flex-col items-center py-2 rounded-md border transition-colors",
                  "focus:outline-none focus-visible:ring-2 focus-visible:ring-accent",
                  isActive
                    ? "bg-ink text-white border-ink"
                    : isToday
                      ? "bg-accent-soft border-accent-soft text-accent"
                      : "bg-surface border-hair text-ink-2 hover:bg-surface-alt"
                )}
              >
                <span className="text-[10px] uppercase tracking-wider font-semibold">
                  {d.toLocaleDateString("en-ZA", { weekday: "short" })}
                </span>
                <span className="serif text-lg tabular leading-none mt-0.5">
                  {d.getDate()}
                </span>
                {dayCount > 0 && (
                  <span
                    className={clsx(
                      "mt-1 h-1 w-1 rounded-full",
                      isActive ? "bg-white" : "bg-accent"
                    )}
                  />
                )}
              </button>
            );
          })}
        </div>

        <div className="card overflow-hidden">
          <header className="px-4 py-3 border-b border-hair flex items-center justify-between gap-3">
            <div className="min-w-0">
              <div className="eyebrow">
                {activeDay.toLocaleDateString("en-ZA", { weekday: "long" })}
              </div>
              <div className="serif text-lg truncate">
                {activeDay.toLocaleDateString("en-ZA", {
                  day: "numeric",
                  month: "long",
                })}
              </div>
            </div>
            <div className="text-xs text-ink-3 tabular shrink-0">
              {activeSchedule && activeSchedule.isOpen
                ? `${activeSchedule.openTime}–${activeSchedule.closeTime}`
                : "Closed"}
            </div>
          </header>

          {activeSchedule && !activeSchedule.isOpen ? (
            <div className="p-10 text-center text-sm text-ink-3">
              Pink&apos;s is closed on this day.
            </div>
          ) : activeDayBookings.length === 0 ? (
            <div className="p-10 text-center text-sm text-ink-3">
              No bookings for this day.
            </div>
          ) : (
            <ul className="divide-y divide-hair">
              {activeDayBookings.map((b) => (
                <li key={b.id}>
                  <Link
                    to={`/bookings/${b.id}`}
                    className="block px-4 py-3 active:bg-surface-alt/60 hover:bg-surface-alt/60 transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-14 text-center shrink-0">
                        <div className="serif text-xl tabular leading-none">
                          {b.startTime}
                        </div>
                        <div className="text-[10px] text-ink-3 mt-1">
                          {b.serviceDurationMinutes}m
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
                        <div className="tabular font-semibold text-sm">
                          {formatRand(b.priceCents)}
                        </div>
                        <div className="mt-1">
                          <StatusChip status={b.status} />
                        </div>
                      </div>
                    </div>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>

      {/* Desktop (lg+): full week timeline */}
      <div className="hidden lg:block card overflow-hidden">
        <div className="overflow-x-auto scrollbar-thin">
          <div className="min-w-[900px]">
            <div className="grid grid-cols-[80px_repeat(7,minmax(0,1fr))] border-b border-hair bg-surface-alt">
              <div />
              {days.map((d) => {
                const dow = ((d.getDay() + 6) % 7) + 1;
                const sch = schedules.find((s) => s.dayOfWeek === dow);
                const isToday = isSameDay(d, new Date());
                return (
                  <div
                    key={d.toISOString()}
                    className={clsx(
                      "px-3 py-3 border-l border-hair",
                      isToday && "bg-accent-soft"
                    )}
                  >
                    <div className="eyebrow">
                      {d.toLocaleDateString("en-ZA", { weekday: "short" })}
                    </div>
                    <div className="serif text-xl tabular">{d.getDate()}</div>
                    <div className="text-[10px] text-ink-3 tabular">
                      {sch && sch.isOpen
                        ? `${sch.openTime}–${sch.closeTime}`
                        : "Closed"}
                    </div>
                  </div>
                );
              })}
            </div>

            <div className="grid grid-cols-[80px_repeat(7,minmax(0,1fr))] relative">
              <div className="relative">
                {hours.map((h) => (
                  <div
                    key={h}
                    className="border-t border-hair text-[10px] text-ink-3 pr-2 text-right tabular"
                    style={{ height: HOUR_HEIGHT }}
                  >
                    <span className="-translate-y-1/2 inline-block">
                      {h.toString().padStart(2, "0")}:00
                    </span>
                  </div>
                ))}
              </div>

              {days.map((d) => {
                const dayBookings = bookings.filter((b) =>
                  isSameDay(b.date, d)
                );
                const dow = ((d.getDay() + 6) % 7) + 1;
                const sch = schedules.find((s) => s.dayOfWeek === dow);
                return (
                  <div
                    key={d.toISOString()}
                    className="relative border-l border-hair"
                    style={{
                      height: hours.length * HOUR_HEIGHT,
                    }}
                  >
                    {hours.map((h) => (
                      <div
                        key={h}
                        className="border-t border-hair"
                        style={{ height: HOUR_HEIGHT }}
                      />
                    ))}

                    {sch &&
                      sch.isOpen &&
                      sch.blocks.map((blk, i) => {
                        const top =
                          ((parseMinutes(blk.start) - dayStartMin) / 60) *
                          HOUR_HEIGHT;
                        const height =
                          ((parseMinutes(blk.end) - parseMinutes(blk.start)) /
                            60) *
                          HOUR_HEIGHT;
                        return (
                          <div
                            key={i}
                            className="absolute inset-x-1 bg-hair/60 border border-hair-2 rounded-sm text-[10px] text-ink-3 px-2 py-1"
                            style={{ top, height }}
                          >
                            {blk.reason}
                          </div>
                        );
                      })}
                    {(!sch || !sch.isOpen) && (
                      <div className="absolute inset-0 bg-surface-alt/60 flex items-center justify-center text-[11px] text-ink-3">
                        Closed
                      </div>
                    )}

                    {dayBookings.map((b) => {
                      const top =
                        ((parseMinutes(b.startTime) - dayStartMin) / 60) *
                        HOUR_HEIGHT;
                      const height =
                        (b.serviceDurationMinutes / 60) * HOUR_HEIGHT;
                      return (
                        <Link
                          key={b.id}
                          to={`/bookings/${b.id}`}
                          className={clsx(
                            "absolute inset-x-1 rounded-md px-2 py-1 text-[11px] overflow-hidden shadow-sm border transition-transform hover:scale-[1.01]",
                            b.status === "confirmed" &&
                              "bg-accent text-accent-ink border-accent",
                            b.status === "pendingPayment" &&
                              "bg-warn-soft text-warn border-warn/30",
                            b.status === "inProgress" &&
                              "bg-ink text-white border-ink",
                            b.status === "completed" &&
                              "bg-success-soft text-success border-success/20",
                            (b.status === "cancelledByCustomer" ||
                              b.status === "cancelledByAdmin" ||
                              b.status === "noShow" ||
                              b.status === "refunded") &&
                              "bg-surface-alt text-ink-3 border-hair line-through"
                          )}
                          style={{ top, height: Math.max(height, 28) }}
                        >
                          <div className="font-semibold tabular">
                            {b.startTime}
                          </div>
                          <div className="truncate">{b.serviceName}</div>
                          <div className="truncate opacity-80">
                            {b.customerName}
                          </div>
                        </Link>
                      );
                    })}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      <div className="mt-4 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
        <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-xs text-ink-3">
          <span className="flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded bg-accent" /> Confirmed
          </span>
          <span className="flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded bg-warn-soft border border-warn/30" />{" "}
            Pending payment
          </span>
          <span className="flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded bg-ink" /> In progress
          </span>
          <span className="flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded bg-success-soft border border-success/20" />{" "}
            Completed
          </span>
        </div>
        <div className="text-xs text-ink-3">
          Tap any card to open the booking.
        </div>
      </div>
    </AppShell>
  );
}
