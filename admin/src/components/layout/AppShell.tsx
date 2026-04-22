import { useEffect, useState, type ReactNode } from "react";
import { useLocation } from "react-router-dom";
import { Sidebar } from "./Sidebar";
import { TopBar } from "./TopBar";

export function AppShell({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle?: string;
  children: ReactNode;
}) {
  const [navOpen, setNavOpen] = useState(false);
  const location = useLocation();

  useEffect(() => {
    setNavOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    if (!navOpen) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, [navOpen]);

  return (
    <div className="min-h-screen w-full flex bg-bg text-ink">
      <Sidebar open={navOpen} onClose={() => setNavOpen(false)} />

      <div className="flex-1 flex flex-col min-w-0 min-h-screen">
        <TopBar
          title={title}
          subtitle={subtitle}
          onOpenNav={() => setNavOpen(true)}
        />
        <main className="flex-1 px-4 sm:px-6 lg:px-8 py-6 md:py-8 max-w-[1600px] w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
