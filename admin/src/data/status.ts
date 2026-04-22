import type { BookingStatus } from "./types";

export const STATUS_LABEL: Record<BookingStatus, string> = {
  pendingPayment: "Pending payment",
  confirmed: "Confirmed",
  inProgress: "In progress",
  completed: "Completed",
  cancelledByCustomer: "Cancelled",
  cancelledByAdmin: "Cancelled (admin)",
  refunded: "Refunded",
  noShow: "No-show",
};

// Returns tailwind classes for the status chip: bg + text.
export function statusChipClass(status: BookingStatus): string {
  switch (status) {
    case "pendingPayment":
      return "bg-warn-soft text-warn";
    case "confirmed":
      return "bg-accent-soft text-accent";
    case "inProgress":
      return "bg-ink text-white";
    case "completed":
      return "bg-success-soft text-success";
    case "cancelledByCustomer":
    case "cancelledByAdmin":
      return "bg-surface-alt text-ink-3";
    case "refunded":
      return "bg-hair text-ink-2";
    case "noShow":
      return "bg-danger-soft text-danger";
  }
}
