import type { ReactNode } from "react";
import clsx from "clsx";

export function StatCard({
  eyebrow,
  value,
  hint,
  accent = false,
  icon,
}: {
  eyebrow: string;
  value: ReactNode;
  hint?: string;
  accent?: boolean;
  icon?: ReactNode;
}) {
  return (
    <div
      className={clsx(
        "card p-4 sm:p-5 flex flex-col gap-2 min-w-0",
        accent && "bg-ink text-white border-ink"
      )}
    >
      <div className="flex items-start justify-between gap-3">
        <div className={clsx("eyebrow truncate", accent && "!text-white/60")}>
          {eyebrow}
        </div>
        {icon && (
          <div
            className={clsx(
              "shrink-0",
              accent ? "text-white/70" : "text-ink-3"
            )}
          >
            {icon}
          </div>
        )}
      </div>
      <div className="serif text-3xl sm:text-4xl leading-tight tabular break-words">
        {value}
      </div>
      {hint && (
        <div
          className={clsx(
            "text-xs",
            accent ? "text-white/60" : "text-ink-3"
          )}
        >
          {hint}
        </div>
      )}
    </div>
  );
}
