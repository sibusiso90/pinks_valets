import { useMemo } from "react";
import { AppShell } from "@/components/layout/AppShell";
import { StatCard } from "@/components/ui/StatCard";
import { useBookings } from "@/data/store";
import { formatRand, formatRandWithCents } from "@/lib/money";
import { formatDateShort } from "@/lib/time";
import type { Booking } from "@/data/types";

export default function Payments() {
  const bookings = useBookings();

  const captured = useMemo(
    () =>
      bookings.filter(
        (b) =>
          b.paymentReference &&
          (b.status === "confirmed" ||
            b.status === "inProgress" ||
            b.status === "completed")
      ),
    [bookings]
  );
  const refunded = useMemo(
    () => bookings.filter((b) => b.status === "refunded"),
    [bookings]
  );
  const pending = useMemo(
    () => bookings.filter((b) => b.status === "pendingPayment"),
    [bookings]
  );

  const capturedTotal = captured.reduce((s, b) => s + b.priceCents, 0);
  const refundedTotal = refunded.reduce((s, b) => s + b.priceCents, 0);
  const pendingTotal = pending.reduce((s, b) => s + b.priceCents, 0);

  const ledger = [...captured, ...refunded].sort(
    (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
  );

  return (
    <AppShell title="Payments" subtitle="Money in, money out">
      <div className="grid grid-cols-2 xl:grid-cols-4 gap-3 sm:gap-4 mb-6">
        <StatCard
          eyebrow="Captured"
          value={formatRand(capturedTotal)}
          hint={`${captured.length} charges`}
          accent
        />
        <StatCard
          eyebrow="Pending"
          value={formatRand(pendingTotal)}
          hint={`${pending.length} awaiting`}
        />
        <StatCard
          eyebrow="Refunded"
          value={formatRand(refundedTotal)}
          hint={`${refunded.length} refunds`}
        />
        <StatCard
          eyebrow="Net"
          value={formatRand(capturedTotal - refundedTotal)}
          hint="captured − refunded"
        />
      </div>

      <div className="card overflow-hidden">
        <div className="px-4 sm:px-5 py-3 border-b border-hair flex items-center justify-between gap-3 flex-wrap">
          <div className="min-w-0">
            <div className="eyebrow">Ledger</div>
            <div className="serif text-lg">Payment history</div>
          </div>
          <div className="text-xs text-ink-3">
            Stubbed v1 — swap in Stripe / PayFast later
          </div>
        </div>

        {ledger.length === 0 ? (
          <div className="p-10 text-center text-sm text-ink-3">
            No payments yet.
          </div>
        ) : (
          <>
            {/* Mobile card list */}
            <ul className="md:hidden divide-y divide-hair">
              {ledger.map((b) => (
                <li
                  key={b.id}
                  className="px-4 py-3 flex items-center justify-between gap-3"
                >
                  <div className="min-w-0">
                    <div className="font-medium truncate">
                      {b.customerName}
                    </div>
                    <div className="text-xs text-ink-3 font-mono truncate">
                      {b.paymentReference ?? "—"}
                    </div>
                    <div className="text-xs text-ink-3 tabular mt-0.5">
                      {formatDateShort(b.createdAt)}
                    </div>
                  </div>
                  <div className="text-right shrink-0">
                    <div
                      className={
                        "tabular font-semibold " +
                        (b.status === "refunded" ? "text-ink-3" : "text-ink")
                      }
                    >
                      {b.status === "refunded" ? "−" : ""}
                      {formatRandWithCents(b.priceCents)}
                    </div>
                    <div className="mt-1">
                      <span
                        className={
                          b.status === "refunded"
                            ? "chip bg-hair text-ink-2"
                            : "chip bg-success-soft text-success"
                        }
                      >
                        {b.status === "refunded" ? "Refunded" : "Captured"}
                      </span>
                    </div>
                  </div>
                </li>
              ))}
            </ul>

            {/* Desktop table */}
            <div className="hidden md:block table-wrap scrollbar-thin">
              <table>
                <thead className="bg-surface-alt text-ink-3">
                  <tr className="text-left">
                    <th className="px-4 py-3 font-semibold">Reference</th>
                    <th className="px-4 py-3 font-semibold">Booking</th>
                    <th className="px-4 py-3 font-semibold">Customer</th>
                    <th className="px-4 py-3 font-semibold">Date</th>
                    <th className="px-4 py-3 font-semibold text-right">
                      Amount
                    </th>
                    <th className="px-4 py-3 font-semibold">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-hair">
                  {ledger.map((b) => (
                    <Row key={b.id} booking={b} />
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
      </div>
    </AppShell>
  );
}

function Row({ booking }: { booking: Booking }) {
  return (
    <tr className="hover:bg-surface-alt/60 transition-colors">
      <td className="px-4 py-3 font-mono text-xs tabular">
        {booking.paymentReference ?? "—"}
      </td>
      <td className="px-4 py-3 font-mono text-xs">{booking.id}</td>
      <td className="px-4 py-3">{booking.customerName}</td>
      <td className="px-4 py-3 tabular">
        {formatDateShort(booking.createdAt)}
      </td>
      <td className="px-4 py-3 text-right tabular font-semibold">
        {booking.status === "refunded" ? "−" : ""}
        {formatRandWithCents(booking.priceCents)}
      </td>
      <td className="px-4 py-3">
        <span
          className={
            booking.status === "refunded"
              ? "chip bg-hair text-ink-2"
              : "chip bg-success-soft text-success"
          }
        >
          {booking.status === "refunded" ? "Refunded" : "Captured"}
        </span>
      </td>
    </tr>
  );
}
