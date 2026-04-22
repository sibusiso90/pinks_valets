import clsx from "clsx";
import type { BookingStatus } from "@/data/types";
import { STATUS_LABEL, statusChipClass } from "@/data/status";

export function StatusChip({ status }: { status: BookingStatus }) {
  return (
    <span
      className={clsx(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-[11px] font-semibold",
        statusChipClass(status)
      )}
    >
      {STATUS_LABEL[status]}
    </span>
  );
}
