import type { ReactNode } from "react";

export function EmptyState({
  title,
  description,
  action,
}: {
  title: string;
  description: string;
  action?: ReactNode;
}) {
  return (
    <div className="card p-10 text-center">
      <div className="serif text-2xl mb-1">{title}</div>
      <div className="text-sm text-ink-3 max-w-md mx-auto">{description}</div>
      {action && <div className="mt-4">{action}</div>}
    </div>
  );
}
