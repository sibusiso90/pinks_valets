import { NavLink } from "react-router-dom";
import {
  LayoutDashboard,
  CalendarDays,
  ClockIcon,
  Sparkles,
  CreditCard,
  Users,
  Settings as SettingsIcon,
  LogOut,
  X,
} from "lucide-react";
import clsx from "clsx";

const items = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard, end: true },
  { to: "/bookings", label: "Bookings", icon: CalendarDays, end: false },
  { to: "/schedule", label: "Schedule", icon: ClockIcon, end: false },
  { to: "/services", label: "Services", icon: Sparkles, end: false },
  { to: "/payments", label: "Payments", icon: CreditCard, end: false },
  { to: "/customers", label: "Customers", icon: Users, end: false },
  { to: "/settings", label: "Settings", icon: SettingsIcon, end: false },
];

export function Sidebar({
  open,
  onClose,
}: {
  open: boolean;
  onClose: () => void;
}) {
  return (
    <>
      {/* Mobile overlay */}
      <div
        className={clsx(
          "fixed inset-0 z-40 bg-ink/50 backdrop-blur-sm lg:hidden transition-opacity",
          open ? "opacity-100" : "opacity-0 pointer-events-none"
        )}
        onClick={onClose}
        aria-hidden="true"
      />

      <aside
        className={clsx(
          "fixed inset-y-0 left-0 z-50 w-72 max-w-[85vw] bg-dark text-white flex flex-col",
          "transition-transform duration-200 ease-out",
          "lg:static lg:w-64 lg:max-w-none lg:translate-x-0 lg:shrink-0",
          open ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
        )}
        aria-label="Primary"
      >
        <div className="px-6 pt-6 pb-8 lg:pt-8 lg:pb-10 flex items-start justify-between">
          <div>
            <div className="flex items-baseline gap-2">
              <span className="wordmark text-4xl text-accent leading-none">
                Pink&apos;s
              </span>
              <span className="text-accent text-lg leading-none">✦</span>
            </div>
            <div className="eyebrow mt-2 text-white/50">Admin Console</div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="lg:hidden -mr-2 h-9 w-9 rounded-md text-white/70 hover:bg-white/10 hover:text-white flex items-center justify-center focus:outline-none focus-visible:ring-2 focus-visible:ring-accent"
            aria-label="Close navigation"
          >
            <X size={20} />
          </button>
        </div>

        <nav className="flex-1 px-3 space-y-0.5 overflow-y-auto">
          {items.map(({ to, label, icon: Icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              className={({ isActive }) =>
                clsx(
                  "flex items-center gap-3 px-3 h-11 lg:h-10 rounded-md text-sm font-medium transition-colors",
                  "focus:outline-none focus-visible:ring-2 focus-visible:ring-accent",
                  isActive
                    ? "bg-white/10 text-white"
                    : "text-white/70 hover:bg-white/5 hover:text-white"
                )
              }
            >
              <Icon size={18} strokeWidth={2} />
              <span>{label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="px-3 pb-6 pt-3 border-t border-white/10">
          <button className="w-full flex items-center gap-3 px-3 h-10 rounded-md text-sm text-white/70 hover:bg-white/5 hover:text-white focus:outline-none focus-visible:ring-2 focus-visible:ring-accent">
            <LogOut size={18} strokeWidth={2} />
            <span>Sign out</span>
          </button>
          <div className="px-3 pt-4 text-[11px] text-white/40">
            v0.1.0 · Africa/Johannesburg
          </div>
        </div>
      </aside>
    </>
  );
}
