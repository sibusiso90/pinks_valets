import { useSyncExternalStore } from "react";
import type {
  Booking,
  Customer,
  DailySchedule,
  ServiceType,
  SystemSettings,
} from "./types";

// Tiny pub/sub so pages can react to edits without pulling in Redux/Zustand.
// Everything is in-memory — this layer is the seam where Firestore wires in later.

type Listener = () => void;

function createStore<T>(initial: T) {
  let state = initial;
  const listeners = new Set<Listener>();
  return {
    get: () => state,
    set: (next: T | ((prev: T) => T)) => {
      state =
        typeof next === "function" ? (next as (p: T) => T)(state) : next;
      listeners.forEach((l) => l());
    },
    subscribe: (l: Listener) => {
      listeners.add(l);
      return () => {
        listeners.delete(l);
      };
    },
  };
}

// ----- Seed data -----

const services: ServiceType[] = [
  {
    id: "express-wash",
    name: "Express Exterior",
    shortDescription: "Foam pre-wash, contactless exterior, dry.",
    priceCents: 22000,
    durationMinutes: 35,
    isActive: true,
    featured: false,
  },
  {
    id: "interior-refresh",
    name: "Interior Refresh",
    shortDescription: "Vacuum, dash wipe-down, window interiors, fragrance.",
    priceCents: 28000,
    durationMinutes: 45,
    isActive: true,
    featured: false,
  },
  {
    id: "full-valet",
    name: "Full Valet",
    shortDescription: "Full interior & exterior — the everyday favourite.",
    priceCents: 45000,
    durationMinutes: 75,
    isActive: true,
    featured: true,
  },
  {
    id: "premium-detail",
    name: "Premium Detail",
    shortDescription: "Clay bar, hand wax, leather condition. 2–3 hours.",
    priceCents: 115000,
    durationMinutes: 180,
    isActive: true,
    featured: false,
  },
  {
    id: "engine-bay",
    name: "Engine Bay Clean",
    shortDescription: "Safe degrease + dress. Often added to a valet.",
    priceCents: 18000,
    durationMinutes: 30,
    isActive: true,
    featured: false,
  },
];

const suburbs = [
  "Sandton",
  "Rosebank",
  "Illovo",
  "Hyde Park",
  "Melrose",
  "Parkhurst",
  "Parktown North",
  "Craighall",
  "Dunkeld",
  "Houghton",
  "Bryanston",
  "Morningside",
  "Rivonia",
  "Fourways",
];

const settings: SystemSettings = {
  travelBufferMinutes: 30,
  slotIncrementMinutes: 30,
  minimumLeadHours: 2,
  cancellationWindowHours: 12,
  serviceAreaSuburbs: suburbs,
  contactPhone: "+27 82 555 0100",
  contactEmail: "hello@pinks.co.za",
};

const schedules: DailySchedule[] = [1, 2, 3, 4, 5].map((d) => ({
  dayOfWeek: d,
  isOpen: true,
  openTime: "07:00",
  closeTime: "18:00",
  blocks: [{ start: "12:00", end: "13:00", reason: "Lunch" }],
}));
schedules.push({
  dayOfWeek: 6,
  isOpen: true,
  openTime: "08:00",
  closeTime: "15:00",
  blocks: [],
});
schedules.push({
  dayOfWeek: 7,
  isOpen: false,
  openTime: "00:00",
  closeTime: "00:00",
  blocks: [],
});

function startOfDay(d: Date) {
  const out = new Date(d);
  out.setHours(0, 0, 0, 0);
  return out;
}

function daysFromNow(n: number) {
  return startOfDay(new Date(Date.now() + n * 86_400_000));
}

const customers: Customer[] = [
  {
    id: "c-001",
    displayName: "Thandi Molefe",
    phone: "+27 82 511 0044",
    email: "thandi.m@example.com",
    createdAt: daysFromNow(-42),
    addressCount: 2,
    completedCount: 5,
  },
  {
    id: "c-002",
    displayName: "Ben Carstens",
    phone: "+27 83 622 1199",
    email: "ben.c@example.com",
    createdAt: daysFromNow(-19),
    addressCount: 1,
    completedCount: 2,
  },
  {
    id: "c-003",
    displayName: "Aisha Patel",
    phone: "+27 71 907 4402",
    email: "aisha.p@example.com",
    createdAt: daysFromNow(-7),
    addressCount: 1,
    completedCount: 0,
  },
  {
    id: "c-004",
    displayName: "Sifiso Dlamini",
    phone: "+27 84 204 8820",
    email: "sifiso.d@example.com",
    createdAt: daysFromNow(-3),
    addressCount: 1,
    completedCount: 0,
  },
];

const bookings: Booking[] = [
  {
    id: "B-2041",
    customerId: "c-001",
    customerName: "Thandi Molefe",
    customerPhone: "+27 82 511 0044",
    serviceId: "full-valet",
    serviceName: "Full Valet",
    serviceDurationMinutes: 75,
    priceCents: 45000,
    date: daysFromNow(0),
    startTime: "10:00",
    address: {
      label: "Home",
      street: "12 Oxford Rd",
      suburb: "Rosebank",
      city: "Johannesburg",
      postalCode: "2196",
    },
    status: "confirmed",
    createdAt: daysFromNow(-2),
    paymentReference: "pay_demo_abc123",
  },
  {
    id: "B-2042",
    customerId: "c-002",
    customerName: "Ben Carstens",
    customerPhone: "+27 83 622 1199",
    serviceId: "express-wash",
    serviceName: "Express Exterior",
    serviceDurationMinutes: 35,
    priceCents: 22000,
    date: daysFromNow(0),
    startTime: "13:30",
    address: {
      label: "Office",
      street: "90 Rivonia Rd",
      suburb: "Sandton",
      city: "Johannesburg",
      postalCode: "2196",
    },
    status: "confirmed",
    createdAt: daysFromNow(-1),
    paymentReference: "pay_demo_def456",
  },
  {
    id: "B-2043",
    customerId: "c-003",
    customerName: "Aisha Patel",
    customerPhone: "+27 71 907 4402",
    serviceId: "interior-refresh",
    serviceName: "Interior Refresh",
    serviceDurationMinutes: 45,
    priceCents: 28000,
    date: daysFromNow(1),
    startTime: "09:00",
    address: {
      label: "Home",
      street: "44 Jan Smuts Ave",
      suburb: "Parkhurst",
      city: "Johannesburg",
      postalCode: "2193",
    },
    status: "confirmed",
    createdAt: daysFromNow(-1),
    paymentReference: "pay_demo_ghi789",
  },
  {
    id: "B-2044",
    customerId: "c-004",
    customerName: "Sifiso Dlamini",
    customerPhone: "+27 84 204 8820",
    serviceId: "full-valet",
    serviceName: "Full Valet",
    serviceDurationMinutes: 75,
    priceCents: 45000,
    date: daysFromNow(2),
    startTime: "11:00",
    address: {
      label: "Home",
      street: "7 Melrose Blvd",
      suburb: "Melrose",
      city: "Johannesburg",
      postalCode: "2196",
    },
    status: "pendingPayment",
    createdAt: daysFromNow(0),
  },
  {
    id: "B-2030",
    customerId: "c-001",
    customerName: "Thandi Molefe",
    customerPhone: "+27 82 511 0044",
    serviceId: "premium-detail",
    serviceName: "Premium Detail",
    serviceDurationMinutes: 180,
    priceCents: 115000,
    date: daysFromNow(-6),
    startTime: "09:00",
    address: {
      label: "Home",
      street: "12 Oxford Rd",
      suburb: "Rosebank",
      city: "Johannesburg",
      postalCode: "2196",
    },
    status: "completed",
    createdAt: daysFromNow(-10),
    paymentReference: "pay_demo_jkl012",
  },
  {
    id: "B-2031",
    customerId: "c-002",
    customerName: "Ben Carstens",
    customerPhone: "+27 83 622 1199",
    serviceId: "express-wash",
    serviceName: "Express Exterior",
    serviceDurationMinutes: 35,
    priceCents: 22000,
    date: daysFromNow(-3),
    startTime: "14:00",
    address: {
      label: "Office",
      street: "90 Rivonia Rd",
      suburb: "Sandton",
      city: "Johannesburg",
      postalCode: "2196",
    },
    status: "completed",
    createdAt: daysFromNow(-5),
    paymentReference: "pay_demo_mno345",
  },
  {
    id: "B-2025",
    customerId: "c-003",
    customerName: "Aisha Patel",
    customerPhone: "+27 71 907 4402",
    serviceId: "full-valet",
    serviceName: "Full Valet",
    serviceDurationMinutes: 75,
    priceCents: 45000,
    date: daysFromNow(-12),
    startTime: "10:30",
    address: {
      label: "Home",
      street: "44 Jan Smuts Ave",
      suburb: "Parkhurst",
      city: "Johannesburg",
      postalCode: "2193",
    },
    status: "cancelledByCustomer",
    createdAt: daysFromNow(-14),
  },
];

// ----- Stores -----

export const servicesStore = createStore<ServiceType[]>(services);
export const bookingsStore = createStore<Booking[]>(bookings);
export const customersStore = createStore<Customer[]>(customers);
export const schedulesStore = createStore<DailySchedule[]>(schedules);
export const settingsStore = createStore<SystemSettings>(settings);

// ----- React hooks -----

export function useServices() {
  return useSyncExternalStore(
    servicesStore.subscribe,
    servicesStore.get,
    servicesStore.get
  );
}
export function useBookings() {
  return useSyncExternalStore(
    bookingsStore.subscribe,
    bookingsStore.get,
    bookingsStore.get
  );
}
export function useCustomers() {
  return useSyncExternalStore(
    customersStore.subscribe,
    customersStore.get,
    customersStore.get
  );
}
export function useSchedules() {
  return useSyncExternalStore(
    schedulesStore.subscribe,
    schedulesStore.get,
    schedulesStore.get
  );
}
export function useSettings() {
  return useSyncExternalStore(
    settingsStore.subscribe,
    settingsStore.get,
    settingsStore.get
  );
}

// ----- Mutations -----

export function updateBookingStatus(
  id: string,
  status: Booking["status"]
) {
  bookingsStore.set((list) =>
    list.map((b) => (b.id === id ? { ...b, status } : b))
  );
}

export function updateService(id: string, patch: Partial<ServiceType>) {
  servicesStore.set((list) =>
    list.map((s) => (s.id === id ? { ...s, ...patch } : s))
  );
}

export function updateSchedule(
  dayOfWeek: number,
  patch: Partial<DailySchedule>
) {
  schedulesStore.set((list) =>
    list.map((s) => (s.dayOfWeek === dayOfWeek ? { ...s, ...patch } : s))
  );
}

export function updateSettings(patch: Partial<SystemSettings>) {
  settingsStore.set((prev) => ({ ...prev, ...patch }));
}
