import { Link, useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, Phone, Mail, MapPin } from "lucide-react";
import { AppShell } from "@/components/layout/AppShell";
import { StatusChip } from "@/components/ui/StatusChip";
import { useBookings, useCustomers } from "@/data/store";
import { formatRand } from "@/lib/money";
import { formatDateShort } from "@/lib/time";

export default function CustomerDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const customers = useCustomers();
  const bookings = useBookings();
  const customer = customers.find((c) => c.id === id);

  if (!customer) {
    return (
      <AppShell title="Customer not found">
        <Link to="/customers" className="btn-soft">
          Back to customers
        </Link>
      </AppShell>
    );
  }

  const theirs = bookings
    .filter((b) => b.customerId === customer.id)
    .sort((a, b) => b.date.getTime() - a.date.getTime());
  const lifetimeCents = theirs
    .filter((b) => b.status === "completed")
    .reduce((s, b) => s + b.priceCents, 0);

  return (
    <AppShell title={customer.displayName} subtitle="Customer profile">
      <button
        onClick={() => navigate(-1)}
        className="btn-ghost mb-4 -ml-3 text-sm"
      >
        <ArrowLeft size={16} /> Back
      </button>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <aside className="card p-4 sm:p-5 h-fit lg:sticky lg:top-24">
          <div className="h-14 w-14 sm:h-16 sm:w-16 rounded-full bg-ink text-white flex items-center justify-center text-lg sm:text-xl font-semibold">
            {customer.displayName
              .split(" ")
              .map((n) => n[0])
              .slice(0, 2)
              .join("")}
          </div>
          <div className="serif text-xl sm:text-2xl mt-3 break-words">
            {customer.displayName}
          </div>
          <div className="mt-3 space-y-2 text-sm text-ink-2">
            <div className="flex items-center gap-2">
              <Phone size={14} className="shrink-0" />
              <span className="truncate">{customer.phone}</span>
            </div>
            <div className="flex items-center gap-2">
              <Mail size={14} className="shrink-0" />
              <span className="truncate">{customer.email}</span>
            </div>
            <div className="flex items-center gap-2">
              <MapPin size={14} className="shrink-0" />
              <span>
                {customer.addressCount} saved address
                {customer.addressCount === 1 ? "" : "es"}
              </span>
            </div>
          </div>
          <div className="mt-5 pt-5 border-t border-hair grid grid-cols-2 gap-3">
            <div>
              <div className="eyebrow">Lifetime</div>
              <div className="serif text-lg sm:text-xl tabular mt-1">
                {formatRand(lifetimeCents)}
              </div>
            </div>
            <div>
              <div className="eyebrow">Jobs</div>
              <div className="serif text-lg sm:text-xl tabular mt-1">
                {theirs.filter((b) => b.status === "completed").length}
              </div>
            </div>
          </div>
        </aside>

        <section className="lg:col-span-2 card overflow-hidden">
          <div className="px-4 sm:px-5 py-3 border-b border-hair">
            <div className="eyebrow">History</div>
            <div className="serif text-lg">
              All bookings · {theirs.length}
            </div>
          </div>
          {theirs.length === 0 ? (
            <div className="p-10 text-center text-sm text-ink-3">
              No bookings yet.
            </div>
          ) : (
            <>
              {/* Mobile card list */}
              <ul className="md:hidden divide-y divide-hair">
                {theirs.map((b) => (
                  <li key={b.id}>
                    <Link
                      to={`/bookings/${b.id}`}
                      className="block px-4 py-3 active:bg-surface-alt/60 hover:bg-surface-alt/60 transition-colors"
                    >
                      <div className="flex items-center justify-between gap-3">
                        <div className="min-w-0">
                          <div className="font-medium truncate">
                            {b.serviceName}
                          </div>
                          <div className="text-xs text-ink-3 tabular">
                            {formatDateShort(b.date)} · {b.startTime}
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

              {/* Desktop table */}
              <div className="hidden md:block table-wrap scrollbar-thin">
                <table>
                  <thead className="bg-surface-alt text-ink-3">
                    <tr className="text-left">
                      <th className="px-4 py-3 font-semibold">Ref</th>
                      <th className="px-4 py-3 font-semibold">Service</th>
                      <th className="px-4 py-3 font-semibold">When</th>
                      <th className="px-4 py-3 font-semibold text-right">
                        Amount
                      </th>
                      <th className="px-4 py-3 font-semibold">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-hair">
                    {theirs.map((b) => (
                      <tr
                        key={b.id}
                        className="hover:bg-surface-alt/60 transition-colors"
                      >
                        <td className="px-4 py-3 font-mono text-xs">
                          <Link
                            to={`/bookings/${b.id}`}
                            className="hover:underline"
                          >
                            {b.id}
                          </Link>
                        </td>
                        <td className="px-4 py-3">{b.serviceName}</td>
                        <td className="px-4 py-3 tabular">
                          {formatDateShort(b.date)} · {b.startTime}
                        </td>
                        <td className="px-4 py-3 text-right tabular">
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
            </>
          )}
        </section>
      </div>
    </AppShell>
  );
}
