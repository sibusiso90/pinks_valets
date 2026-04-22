import { useState } from "react";
import { Sparkles } from "lucide-react";
import clsx from "clsx";
import { AppShell } from "@/components/layout/AppShell";
import { useServices, updateService } from "@/data/store";
import { formatRand } from "@/lib/money";
import { formatDurationShort } from "@/lib/time";
import type { ServiceType } from "@/data/types";

export default function Services() {
  const services = useServices();
  const [editingId, setEditingId] = useState<string | null>(null);

  return (
    <AppShell title="Services" subtitle="The menu customers book from">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3 sm:gap-4">
        {services.map((s) => (
          <ServiceCard
            key={s.id}
            service={s}
            editing={editingId === s.id}
            onEdit={() => setEditingId(s.id)}
            onCancel={() => setEditingId(null)}
            onSave={(patch) => {
              updateService(s.id, patch);
              setEditingId(null);
            }}
          />
        ))}
      </div>
    </AppShell>
  );
}

function ServiceCard({
  service,
  editing,
  onEdit,
  onCancel,
  onSave,
}: {
  service: ServiceType;
  editing: boolean;
  onEdit: () => void;
  onCancel: () => void;
  onSave: (patch: Partial<ServiceType>) => void;
}) {
  const [name, setName] = useState(service.name);
  const [desc, setDesc] = useState(service.shortDescription);
  const [price, setPrice] = useState(Math.round(service.priceCents / 100));
  const [duration, setDuration] = useState(service.durationMinutes);
  const [active, setActive] = useState(service.isActive);
  const [featured, setFeatured] = useState(service.featured);

  if (!editing) {
    return (
      <div
        className={clsx(
          "card p-4 sm:p-5",
          !service.isActive && "opacity-60",
          service.featured && "ring-2 ring-accent/30"
        )}
      >
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0 flex-1">
            <div className="flex items-center gap-2 flex-wrap">
              <div className="serif text-xl sm:text-2xl">{service.name}</div>
              {service.featured && (
                <span className="chip-accent">
                  <Sparkles size={12} /> Featured
                </span>
              )}
              {!service.isActive && <span className="chip">Hidden</span>}
            </div>
            <div className="text-sm text-ink-3 mt-1 break-words">
              {service.shortDescription}
            </div>
          </div>
          <button className="btn-soft text-sm shrink-0" onClick={onEdit}>
            Edit
          </button>
        </div>
        <div className="mt-4 grid grid-cols-2 gap-4">
          <div>
            <div className="eyebrow">Price</div>
            <div className="serif text-xl tabular mt-1">
              {formatRand(service.priceCents)}
            </div>
          </div>
          <div>
            <div className="eyebrow">Duration</div>
            <div className="serif text-xl mt-1">
              {formatDurationShort(service.durationMinutes)}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="card p-4 sm:p-5">
      <div className="space-y-3">
        <div>
          <label className="eyebrow block">Name</label>
          <input
            className="input mt-1"
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
        </div>
        <div>
          <label className="eyebrow block">Short description</label>
          <textarea
            className="input mt-1 h-20 py-2"
            value={desc}
            onChange={(e) => setDesc(e.target.value)}
          />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label className="eyebrow block">Price (R)</label>
            <input
              type="number"
              className="input mt-1 tabular"
              value={price}
              onChange={(e) => setPrice(parseInt(e.target.value || "0", 10))}
            />
          </div>
          <div>
            <label className="eyebrow block">Duration (min)</label>
            <input
              type="number"
              className="input mt-1 tabular"
              value={duration}
              onChange={(e) =>
                setDuration(parseInt(e.target.value || "0", 10))
              }
            />
          </div>
        </div>
        <div className="flex flex-col sm:flex-row sm:items-center gap-3 sm:gap-6 pt-1">
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={active}
              onChange={(e) => setActive(e.target.checked)}
            />
            Active (visible to customers)
          </label>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={featured}
              onChange={(e) => setFeatured(e.target.checked)}
            />
            Featured
          </label>
        </div>
      </div>
      <div className="mt-4 flex flex-col sm:flex-row gap-2 sm:justify-end">
        <button className="btn-ghost" onClick={onCancel}>
          Cancel
        </button>
        <button
          className="btn-accent"
          onClick={() =>
            onSave({
              name,
              shortDescription: desc,
              priceCents: price * 100,
              durationMinutes: duration,
              isActive: active,
              featured,
            })
          }
        >
          Save changes
        </button>
      </div>
    </div>
  );
}
