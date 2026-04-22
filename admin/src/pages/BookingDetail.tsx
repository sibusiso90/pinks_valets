import { Link, useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, MapPin, Phone, Mail } from "lucide-react";
import { AppShell } from "@/components/layout/AppShell";
import { StatusChip } from "@/components/ui/StatusChip";
import { useBookings, updateBookingStatus } from "@/data/store";
import { formatRand } from "@/lib/money";
import { formatDateLong } from "@/lib/time";
import { STATUS_LABEL } from "@/data/status";
import type { BookingStatus } from "@/data/types";

const TRANSITIONS: Partial<Record<BookingStatus, BookingStatus[]>> = {
  pendingPayment: ["confirmed", "cancelledByAdmin"],
  confirmed: ["inProgress", "cancelledByAdmin", "noShow"],
  inProgress: ["completed", "cancelledByAdmin"],
  completed: ["refunded"],
};

export default function BookingDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const bookings = useBookings();
  const booking = bookings.find((b) => b.id === id);

  if (!booking) {
    return (
      <AppShell title="Booking not found">
        <Link to="/bookings" className="btn-soft">
          Back to bookings
        </Link>
      </AppShell>
    );
  }

  const next = TRANSITIONS[booking.status] ?? [];

  return (
    <AppShell title={`Booking ${booking.id}`} subtitle={booking.serviceName}>
      <button
        onClick={() => navigate(-1)}
        className="btn-ghost mb-4 -ml-3 text-sm"
      >
        <ArrowLeft size={16} /> Back
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <section className="lg:col-span-2 space-y-4 min-w-0">
          <div className="card p-4 sm:p-5">
            <div className="flex items-start justify-between gap-3 flex-wrap">
              <div className="min-w-0">
                <div className="eyebrow">Service</div>
                <div className="serif text-2xl sm:text-3xl mt-1 break-words">
                  {booking.serviceName}
                </div>
                <div className="text-sm text-ink-3 mt-1 tabular">
                  {booking.serviceDurationMinutes} min ·{" "}
                  {formatRand(booking.priceCents)}
                </div>
              </div>
              <StatusChip status={booking.status} />
            </div>
          </div>

          <div className="card p-4 sm:p-5 grid grid-cols-1 sm:grid-cols-2 gap-6">
            <div>
              <div className="eyebrow">When</div>
              <div className="serif text-xl mt-1 tabular">
                {booking.startTime}
              </div>
              <div className="text-sm text-ink-3">
                {formatDateLong(booking.date)}
              </div>
            </div>
            <div>
              <div className="eyebrow">Service area</div>
              <div className="mt-1 flex items-start gap-2">
                <MapPin size={16} className="mt-0.5 text-ink-3 shrink-0" />
                <div className="min-w-0">
                  <div className="font-medium break-words">
                    {booking.address.label}
                    {booking.address.label && " · "}
                    {booking.address.street}
                  </div>
                  <div className="text-sm text-ink-3 break-words">
                    {booking.address.suburb}, {booking.address.city}{" "}
                    {booking.address.postalCode}
                  </div>
                  {booking.address.notes && (
                    <div className="text-sm text-ink-3 mt-1 break-words">
                      “{booking.address.notes}”
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>

          <div className="card p-4 sm:p-5">
            <div className="eyebrow mb-2">Timeline</div>
            <ul className="space-y-3 text-sm">
              <li className="flex items-start gap-3">
                <div className="h-2 w-2 mt-2 rounded-full bg-accent shrink-0" />
                <div className="min-w-0">
                  <div className="font-medium">Booking created</div>
                  <div className="text-ink-3 text-xs tabular">
                    {booking.createdAt.toLocaleString("en-ZA")}
                  </div>
                </div>
              </li>
              {booking.paymentReference && (
                <li className="flex items-start gap-3">
                  <div className="h-2 w-2 mt-2 rounded-full bg-success shrink-0" />
                  <div className="min-w-0">
                    <div className="font-medium break-words">
                      Payment captured · {booking.paymentReference}
                    </div>
                    <div className="text-ink-3 text-xs">
                      {formatRand(booking.priceCents)}
                    </div>
                  </div>
                </li>
              )}
              <li className="flex items-start gap-3">
                <div className="h-2 w-2 mt-2 rounded-full bg-ink shrink-0" />
                <div className="min-w-0">
                  <div className="font-medium">
                    Current status · {STATUS_LABEL[booking.status]}
                  </div>
                </div>
              </li>
            </ul>
          </div>
        </section>

        <aside className="space-y-4 min-w-0">
          <div className="card p-4 sm:p-5">
            <div className="eyebrow">Customer</div>
            <div className="serif text-xl mt-1 break-words">
              {booking.customerName}
            </div>
            <div className="mt-3 space-y-2 text-sm">
              <div className="flex items-center gap-2 text-ink-2">
                <Phone size={14} className="shrink-0" />
                <span className="truncate">{booking.customerPhone}</span>
              </div>
              <div className="flex items-center gap-2 text-ink-2">
                <Mail size={14} className="shrink-0" />
                <span className="truncate">
                  {booking.customerId}@demo.pinks
                </span>
              </div>
            </div>
            <Link
              to={`/customers/${booking.customerId}`}
              className="btn-soft w-full mt-4 text-sm"
            >
              View customer
            </Link>
          </div>

          <div className="card p-4 sm:p-5">
            <div className="eyebrow">Actions</div>
            {next.length === 0 ? (
              <div className="mt-3 text-sm text-ink-3">
                No further transitions available.
              </div>
            ) : (
              <div className="mt-3 space-y-2">
                {next.map((s) => (
                  <button
                    key={s}
                    onClick={() => updateBookingStatus(booking.id, s)}
                    className={
                      s.startsWith("cancel") || s === "noShow" || s === "refunded"
                        ? "btn-soft w-full"
                        : "btn-accent w-full"
                    }
                  >
                    Mark {STATUS_LABEL[s].toLowerCase()}
                  </button>
                ))}
              </div>
            )}
          </div>
        </aside>
      </div>
    </AppShell>
  );
}
