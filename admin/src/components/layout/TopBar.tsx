import { useState } from "react";
import { Bell, Menu, Search, X } from "lucide-react";

export function TopBar({
  title,
  subtitle,
  onOpenNav,
}: {
  title: string;
  subtitle?: string;
  onOpenNav: () => void;
}) {
  const [searchOpen, setSearchOpen] = useState(false);

  return (
    <header className="sticky top-0 z-30 bg-bg/85 backdrop-blur border-b border-hair">
      <div className="px-4 sm:px-6 lg:px-8 h-16 md:h-20 flex items-center gap-3 max-w-[1600px] mx-auto">
        <button
          type="button"
          onClick={onOpenNav}
          className="lg:hidden -ml-2 h-10 w-10 rounded-md text-ink-2 hover:bg-surface-alt flex items-center justify-center focus:outline-none focus-visible:ring-2 focus-visible:ring-accent"
          aria-label="Open navigation"
        >
          <Menu size={20} />
        </button>

        <div className="flex-1 min-w-0">
          <div className="eyebrow hidden sm:block">Today</div>
          <h1 className="serif text-xl sm:text-2xl md:text-3xl leading-tight text-ink truncate">
            {title}
          </h1>
          {subtitle && (
            <div className="text-xs sm:text-sm text-ink-3 mt-0.5 truncate">
              {subtitle}
            </div>
          )}
        </div>

        <div className="flex items-center gap-2 sm:gap-3">
          <div className="relative hidden md:block">
            <Search
              size={16}
              className="absolute left-3 top-1/2 -translate-y-1/2 text-ink-3 pointer-events-none"
            />
            <input
              className="input pl-9 w-56 lg:w-72"
              placeholder="Search bookings, customers…"
              aria-label="Search"
            />
          </div>

          <button
            type="button"
            onClick={() => setSearchOpen(true)}
            className="md:hidden h-10 w-10 rounded-md border border-hair bg-surface flex items-center justify-center text-ink-2 hover:bg-surface-alt focus:outline-none focus-visible:ring-2 focus-visible:ring-accent"
            aria-label="Open search"
          >
            <Search size={18} />
          </button>

          <button
            type="button"
            className="h-10 w-10 rounded-md border border-hair bg-surface flex items-center justify-center text-ink-2 hover:bg-surface-alt focus:outline-none focus-visible:ring-2 focus-visible:ring-accent relative"
            aria-label="Notifications"
          >
            <Bell size={18} />
            <span className="absolute top-2 right-2 h-1.5 w-1.5 rounded-full bg-accent" />
          </button>

          <div
            className="h-9 w-9 sm:h-10 sm:w-10 rounded-full bg-ink text-white flex items-center justify-center text-sm font-semibold shrink-0"
            title="Pink's Admin"
          >
            PA
          </div>
        </div>
      </div>

      {searchOpen && (
        <div className="md:hidden border-t border-hair bg-bg px-4 py-3">
          <div className="relative">
            <Search
              size={16}
              className="absolute left-3 top-1/2 -translate-y-1/2 text-ink-3 pointer-events-none"
            />
            <input
              autoFocus
              className="input pl-9 pr-10 w-full"
              placeholder="Search bookings, customers…"
              aria-label="Search"
            />
            <button
              type="button"
              onClick={() => setSearchOpen(false)}
              className="absolute right-1 top-1/2 -translate-y-1/2 h-8 w-8 rounded-md text-ink-3 hover:bg-surface-alt flex items-center justify-center"
              aria-label="Close search"
            >
              <X size={16} />
            </button>
          </div>
        </div>
      )}
    </header>
  );
}
