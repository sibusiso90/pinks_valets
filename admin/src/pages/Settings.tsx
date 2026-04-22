import { useState } from "react";
import { X } from "lucide-react";
import { AppShell } from "@/components/layout/AppShell";
import {
  useSchedules,
  useSettings,
  updateSchedule,
  updateSettings,
} from "@/data/store";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const DAYS_LONG = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

export default function Settings() {
  const schedules = useSchedules();
  const settings = useSettings();
  const [newSuburb, setNewSuburb] = useState("");

  return (
    <AppShell title="Settings" subtitle="Hours, service area, rules">
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-3 sm:gap-4">
        <section className="card p-4 sm:p-5">
          <div className="eyebrow">Working hours</div>
          <div className="serif text-lg sm:text-xl mt-0.5 mb-4">
            Weekly schedule
          </div>
          <div className="space-y-3">
            {[1, 2, 3, 4, 5, 6, 7].map((dow) => {
              const s = schedules.find((x) => x.dayOfWeek === dow);
              if (!s) return null;
              return (
                <div
                  key={dow}
                  className="flex flex-col sm:grid sm:grid-cols-[72px_1fr_1fr_auto] items-stretch sm:items-center gap-2 sm:gap-3 pb-3 sm:pb-0 border-b sm:border-0 border-hair last:border-0"
                >
                  <div className="font-semibold flex items-center justify-between sm:block">
                    <span className="sm:hidden">{DAYS_LONG[dow - 1]}</span>
                    <span className="hidden sm:inline">{DAYS[dow - 1]}</span>
                    <label className="flex items-center gap-2 text-sm sm:hidden">
                      <input
                        type="checkbox"
                        checked={s.isOpen}
                        onChange={(e) =>
                          updateSchedule(dow, { isOpen: e.target.checked })
                        }
                      />
                      Open
                    </label>
                  </div>
                  <input
                    type="time"
                    disabled={!s.isOpen}
                    value={s.openTime}
                    onChange={(e) =>
                      updateSchedule(dow, { openTime: e.target.value })
                    }
                    className="input tabular disabled:opacity-40"
                    aria-label={`${DAYS_LONG[dow - 1]} opening time`}
                  />
                  <input
                    type="time"
                    disabled={!s.isOpen}
                    value={s.closeTime}
                    onChange={(e) =>
                      updateSchedule(dow, { closeTime: e.target.value })
                    }
                    className="input tabular disabled:opacity-40"
                    aria-label={`${DAYS_LONG[dow - 1]} closing time`}
                  />
                  <label className="hidden sm:flex items-center gap-2 text-sm whitespace-nowrap">
                    <input
                      type="checkbox"
                      checked={s.isOpen}
                      onChange={(e) =>
                        updateSchedule(dow, { isOpen: e.target.checked })
                      }
                    />
                    Open
                  </label>
                </div>
              );
            })}
          </div>
        </section>

        <section className="card p-4 sm:p-5">
          <div className="eyebrow">Booking rules</div>
          <div className="serif text-lg sm:text-xl mt-0.5 mb-4">
            Lead time &amp; buffers
          </div>
          <div className="space-y-3">
            <Row label="Minimum lead time (hours)">
              <input
                type="number"
                className="input tabular w-full sm:w-24"
                value={settings.minimumLeadHours}
                onChange={(e) =>
                  updateSettings({
                    minimumLeadHours: parseInt(e.target.value || "0", 10),
                  })
                }
              />
            </Row>
            <Row label="Travel buffer between jobs (min)">
              <input
                type="number"
                className="input tabular w-full sm:w-24"
                value={settings.travelBufferMinutes}
                onChange={(e) =>
                  updateSettings({
                    travelBufferMinutes: parseInt(
                      e.target.value || "0",
                      10
                    ),
                  })
                }
              />
            </Row>
            <Row label="Slot increment (min)">
              <input
                type="number"
                className="input tabular w-full sm:w-24"
                value={settings.slotIncrementMinutes}
                onChange={(e) =>
                  updateSettings({
                    slotIncrementMinutes: parseInt(
                      e.target.value || "0",
                      10
                    ),
                  })
                }
              />
            </Row>
            <Row label="Cancellation window (hours)">
              <input
                type="number"
                className="input tabular w-full sm:w-24"
                value={settings.cancellationWindowHours}
                onChange={(e) =>
                  updateSettings({
                    cancellationWindowHours: parseInt(
                      e.target.value || "0",
                      10
                    ),
                  })
                }
              />
            </Row>
          </div>
        </section>

        <section className="card p-4 sm:p-5 xl:col-span-2">
          <div className="flex flex-col sm:flex-row sm:items-baseline sm:justify-between gap-2 mb-4">
            <div>
              <div className="eyebrow">Service area</div>
              <div className="serif text-lg sm:text-xl mt-0.5">
                Suburbs Pink&apos;s will drive to
              </div>
            </div>
            <div className="text-sm text-ink-3">
              {settings.serviceAreaSuburbs.length} suburbs
            </div>
          </div>
          <div className="flex flex-wrap gap-2">
            {settings.serviceAreaSuburbs.map((s) => (
              <span
                key={s}
                className="chip flex items-center gap-1.5 pr-1.5"
              >
                {s}
                <button
                  onClick={() =>
                    updateSettings({
                      serviceAreaSuburbs:
                        settings.serviceAreaSuburbs.filter((x) => x !== s),
                    })
                  }
                  className="h-5 w-5 rounded-full hover:bg-ink hover:text-white flex items-center justify-center transition-colors"
                  aria-label={`Remove ${s}`}
                >
                  <X size={12} />
                </button>
              </span>
            ))}
          </div>
          <form
            className="mt-4 flex flex-col sm:flex-row items-stretch sm:items-center gap-2"
            onSubmit={(e) => {
              e.preventDefault();
              const trimmed = newSuburb.trim();
              if (!trimmed) return;
              if (settings.serviceAreaSuburbs.includes(trimmed)) return;
              updateSettings({
                serviceAreaSuburbs: [
                  ...settings.serviceAreaSuburbs,
                  trimmed,
                ],
              });
              setNewSuburb("");
            }}
          >
            <input
              className="input sm:max-w-xs"
              placeholder="Add suburb…"
              value={newSuburb}
              onChange={(e) => setNewSuburb(e.target.value)}
              aria-label="Add a suburb"
            />
            <button type="submit" className="btn-accent sm:shrink-0">
              Add suburb
            </button>
          </form>
        </section>

        <section className="card p-4 sm:p-5 xl:col-span-2">
          <div className="eyebrow">Contact</div>
          <div className="serif text-lg sm:text-xl mt-0.5 mb-4">
            How customers reach Pink&apos;s
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="eyebrow block">Support phone</label>
              <input
                className="input mt-1"
                value={settings.contactPhone}
                onChange={(e) =>
                  updateSettings({ contactPhone: e.target.value })
                }
              />
            </div>
            <div>
              <label className="eyebrow block">Support email</label>
              <input
                className="input mt-1"
                type="email"
                value={settings.contactEmail}
                onChange={(e) =>
                  updateSettings({ contactEmail: e.target.value })
                }
              />
            </div>
          </div>
        </section>
      </div>
    </AppShell>
  );
}

function Row({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
      <div className="text-sm text-ink-2">{label}</div>
      <div className="sm:shrink-0">{children}</div>
    </div>
  );
}
