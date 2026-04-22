// Firestore-shaped domain types. Money stored as cents; times as "HH:mm".
export type BookingStatus =
  | "pendingPayment"
  | "confirmed"
  | "inProgress"
  | "completed"
  | "cancelledByCustomer"
  | "cancelledByAdmin"
  | "refunded"
  | "noShow";

export interface ServiceType {
  id: string;
  name: string;
  shortDescription: string;
  priceCents: number;
  durationMinutes: number;
  isActive: boolean;
  featured: boolean;
}

export interface Address {
  label: string;
  street: string;
  suburb: string;
  city: string;
  postalCode: string;
  notes?: string;
}

export interface Customer {
  id: string;
  displayName: string;
  phone: string;
  email: string;
  createdAt: Date;
  addressCount: number;
  completedCount: number;
}

export interface Booking {
  id: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  serviceId: string;
  serviceName: string;
  serviceDurationMinutes: number;
  priceCents: number;
  date: Date; // start of day
  startTime: string; // "HH:mm"
  address: Address;
  status: BookingStatus;
  createdAt: Date;
  paymentReference?: string;
  notes?: string;
}

export interface TimeBlock {
  start: string; // "HH:mm"
  end: string; // "HH:mm"
  reason: string;
}

export interface DailySchedule {
  dayOfWeek: number; // 1=Mon ... 7=Sun
  isOpen: boolean;
  openTime: string;
  closeTime: string;
  blocks: TimeBlock[];
}

export interface SystemSettings {
  travelBufferMinutes: number;
  slotIncrementMinutes: number;
  minimumLeadHours: number;
  cancellationWindowHours: number;
  serviceAreaSuburbs: string[];
  contactPhone: string;
  contactEmail: string;
}
