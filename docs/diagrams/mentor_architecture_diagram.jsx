import { useState } from "react";

// ─── palette ───────────────────────────────────────────────────────────────
const P = {
  bg:      "#080d18",
  card:    "#0d1525",
  card2:   "#111827",
  border:  "#1e2d45",
  user:    "#f59e0b",
  coord:   "#6366f1",
  mentor:  "#8b5cf6",
  signal:  "#0ea5e9",
  memory:  "#06b6d4",
  file:    "#475569",
  orch:    "#6366f1",
  domain:  "#8b5cf6",
  output:  "#10b981",
  cp:      "#f59e0b",
  text:    "#f1f5f9",
  sub:     "#94a3b8",
  dim:     "#334155",
  green:   "#22c55e",
  red:     "#ef4444",
};

// ─── primitives ────────────────────────────────────────────────────────────
const T = ({ c = P.text, s = 11, w = 400, children, style }) => (
  <span style={{ color: c, fontSize: s, fontWeight: w, ...style }}>{children}</span>
);

const Tag = ({ label, color }) => (
  <span style={{
    background: `${color}20`, border: `1px solid ${color}55`,
    color, fontSize: 8, padding: "1px 5px", borderRadius: 8,
    fontWeight: 700, letterSpacing: 0.5, marginLeft: 4, whiteSpace: "nowrap",
  }}>{label}</span>
);

const Divider = ({ color = P.coord, label }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 8, margin: "6px 0" }}>
    <div style={{ flex: 1, height: 1, background: `${color}30` }} />
    {label && <span style={{ color, fontSize: 8, fontWeight: 700, letterSpacing: 1, opacity: 0.7 }}>{label}</span>}
    <div style={{ flex: 1, height: 1, background: `${color}30` }} />
  </div>
);

const Arrow = ({ down = true, color = P.dim }) => (
  <div style={{ display: "flex", justifyContent: "center", margin: "2px 0" }}>
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 0 }}>
      <div style={{ width: 1, height: 10, background: color }} />
      <div style={{ width: 0, height: 0,
        borderLeft: "4px solid transparent",
        borderRight: "4px solid transparent",
        borderTop: `5px solid ${color}`,
      }} />
    </div>
  </div>
);

// ─── left panel: flow pipeline ─────────────────────────────────────────────
const FlowBox = ({ icon, title, subtitle, color, children, glow }) => (
  <div style={{
    border: `1px solid ${color}44`,
    borderLeft: `3px solid ${color}`,
    borderRadius: 8,
    background: P.card,
    padding: "10px 12px",
    boxShadow: glow ? `0 0 12px ${color}22` : "none",
  }}>
    <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: children ? 8 : 0 }}>
      {icon && <span style={{ fontSize: 14, flexShrink: 0 }}>{icon}</span>}
      <div>
        <div style={{ fontSize: 12, fontWeight: 700, color, lineHeight: 1.3 }}>{title}</div>
        {subtitle && <div style={{ fontSize: 9, color: P.sub, marginTop: 1 }}>{subtitle}</div>}
      </div>
    </div>
    {children}
  </div>
);

const CheckpointBox = ({ n, title, detail }) => (
  <div style={{
    border: `1.5px solid ${P.cp}`,
    borderRadius: 8,
    background: `${P.cp}0d`,
    padding: "10px 14px",
    display: "flex",
    gap: 12,
    alignItems: "flex-start",
    boxShadow: `0 0 16px ${P.cp}18`,
  }}>
    <div style={{
      background: P.cp, color: "#000", fontWeight: 900, fontSize: 11,
      width: 30, height: 30, borderRadius: "50%", flexShrink: 0,
      display: "flex", alignItems: "center", justifyContent: "center",
    }}>⏸{n}</div>
    <div>
      <div style={{ fontSize: 12, fontWeight: 700, color: P.cp }}>{title}</div>
      <div style={{ fontSize: 10, color: `${P.cp}99`, marginTop: 3, lineHeight: 1.5 }}>{detail}</div>
    </div>
    <div style={{ marginLeft: "auto", flexShrink: 0 }}>
      <div style={{ fontSize: 8, fontWeight: 800, color: P.cp, letterSpacing: 0.5,
        border: `1px solid ${P.cp}55`, borderRadius: 4, padding: "2px 6px" }}>WAIT</div>
    </div>
  </div>
);

const MentorCluster = () => {
  const domains = [
    { name: "FITNESS", color: "#f97316" },
    { name: "MUSIC",   color: "#ec4899" },
    { name: "NEURO",   color: "#a78bfa" },
    { name: "MRI",     color: "#34d399" },
    { name: "HC CO.",  color: "#60a5fa" },
    { name: "READING", color: "#fb923c" },
  ];
  return (
    <div style={{
      border: `1px solid ${P.mentor}44`, borderLeft: `3px solid ${P.mentor}`,
      borderRadius: 8, background: P.card, padding: "10px 12px",
    }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
        <span style={{ fontSize: 14 }}>🤖</span>
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: P.mentor }}>Mentor Agents — parallel</div>
          <div style={{ fontSize: 9, color: P.sub }}>One agent per active/seeding domain · run simultaneously</div>
        </div>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 5 }}>
        {domains.map(d => (
          <div key={d.name} style={{
            background: `${d.color}10`, border: `1px solid ${d.color}44`,
            borderRadius: 6, padding: "6px 8px", textAlign: "center",
          }}>
            <div style={{ fontSize: 9, fontWeight: 700, color: d.color }}>{d.name}</div>
            <div style={{ fontSize: 8, color: P.sub, marginTop: 2 }}>agent</div>
          </div>
        ))}
      </div>
      <Divider color={P.mentor} label="each agent reads" />
      <div style={{ display: "flex", gap: 4, flexWrap: "wrap" }}>
        {["curriculum.md", "log.md", "intel.md", "prateek.md"].map(f => (
          <span key={f} style={{
            background: `${P.domain}15`, border: `1px solid ${P.domain}33`,
            color: P.sub, fontSize: 8, padding: "1px 6px", borderRadius: 4,
            fontFamily: "monospace",
          }}>{f}</span>
        ))}
      </div>
      <Divider color={P.mentor} label="each returns" />
      <div style={{ fontSize: 9, color: P.sub, lineHeight: 1.7 }}>
        <span style={{ color: P.mentor }}>MENTOR_REPORT:</span>{" "}
        week assessment · curriculum position · gap analysis · difficulty signal · next week goals · log entry
      </div>
    </div>
  );
};

// ─── right panel: file ecosystem ──────────────────────────────────────────
const FileLayer = ({ title, color, files }) => (
  <div style={{
    border: `1px solid ${color}25`,
    borderLeft: `2px solid ${color}`,
    borderRadius: 6,
    background: P.card,
    padding: "8px 10px",
    marginBottom: 6,
  }}>
    <div style={{ fontSize: 8, fontWeight: 800, color, letterSpacing: 1.2,
      textTransform: "uppercase", marginBottom: 6, opacity: 0.9 }}>{title}</div>
    {files.map(f => (
      <div key={f.name} style={{
        display: "flex", alignItems: "center", justifyContent: "space-between",
        padding: "3px 0", borderBottom: `1px solid ${P.border}`,
      }}>
        <div>
          <span style={{ fontSize: 10, fontFamily: "monospace", color: P.text, fontWeight: 600 }}>{f.name}</span>
          {f.sub && <span style={{ fontSize: 9, color: P.sub, marginLeft: 5 }}>{f.sub}</span>}
        </div>
        <div style={{ display: "flex", gap: 3, flexShrink: 0, marginLeft: 8 }}>
          {f.read  && <Tag label="R" color={P.signal} />}
          {f.write && <Tag label="W" color={P.output} />}
          {f.flag  && <Tag label={f.flag} color={P.user} />}
        </div>
      </div>
    ))}
  </div>
);

const Legend = () => (
  <div style={{
    display: "flex", gap: 12, flexWrap: "wrap",
    fontSize: 9, color: P.sub, marginTop: 8,
    padding: "8px 10px",
    background: P.card, borderRadius: 6,
    border: `1px solid ${P.border}`,
  }}>
    {[
      { color: P.user,   label: "User interaction" },
      { color: P.coord,  label: "Coordinator agent" },
      { color: P.mentor, label: "Mentor agents" },
      { color: P.signal, label: "Signal read" },
      { color: P.output, label: "Write output" },
      { color: P.cp,     label: "Human checkpoint ⏸" },
    ].map(({ color, label }) => (
      <div key={label} style={{ display: "flex", alignItems: "center", gap: 5 }}>
        <div style={{ width: 10, height: 10, borderRadius: 2,
          background: `${color}30`, border: `1.5px solid ${color}` }} />
        {label}
      </div>
    ))}
    <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
      <Tag label="R" color={P.signal} />{" read"}
    </div>
    <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
      <Tag label="W" color={P.output} />{" write"}
    </div>
  </div>
);

// ─── main ──────────────────────────────────────────────────────────────────
export default function App() {
  const [hovered, setHovered] = useState(null);

  return (
    <div style={{ background: P.bg, minHeight: "100vh", color: P.text,
      fontFamily: "system-ui, -apple-system, sans-serif", padding: 20 }}>
      <div style={{ maxWidth: 1040, margin: "0 auto" }}>

        {/* header */}
        <div style={{ marginBottom: 16 }}>
          <div style={{ fontSize: 18, fontWeight: 800, color: P.text, letterSpacing: -0.3 }}>
            Life Mentor System — Architecture
          </div>
          <div style={{ fontSize: 11, color: P.sub, marginTop: 4 }}>
            11-domain multi-agent weekly review · Todoist as primary signal ·
            2 human checkpoints · Apr 2026
          </div>
        </div>

        <Legend />

        <div style={{ height: 16 }} />

        {/* two-column layout */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 340px", gap: 16, alignItems: "start" }}>

          {/* ── LEFT: weekly review pipeline ── */}
          <div>
            <div style={{ fontSize: 9, fontWeight: 800, color: P.coord, letterSpacing: 1.5,
              textTransform: "uppercase", marginBottom: 8, opacity: 0.7 }}>
              Weekly Review Pipeline — triggered by "weekly review"
            </div>

            {/* PRATEEK */}
            <FlowBox icon="👤" title="Prateek" color={P.user}
              subtitle='Says "weekly review" · responds at 2 checkpoints · everything else is autonomous' />

            <Arrow color={P.user} />

            {/* PHASE 1 */}
            <FlowBox icon="🔍" title="Phase 1 — Coordinator gathers signals" color={P.coord}
              subtitle="No agents yet. Coordinator reads all sources and builds the WEEK_BRIEF.">
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 4 }}>
                {[
                  { icon: "📋", label: "Todoist", sub: "3-layer: tasks + comments (verbatim) + overdue", color: P.signal },
                  { icon: "📄", label: "TRACKER.md", sub: "cross-reference fallback", color: P.user },
                  { icon: "🧠", label: "prateek.md", sub: "behavioral profile + energy patterns", color: P.orch },
                  { icon: "🌐", label: "auto-memory", sub: "wide net — cross-session signals", color: P.memory },
                  { icon: "📅", label: "season_current.md", sub: "domain states, locked slots", color: P.orch },
                  { icon: "🔗", label: "cross_domain.md", sub: "scheduling constraints, synergies", color: P.orch },
                ].map(s => (
                  <div key={s.label} style={{
                    background: `${s.color}0c`, border: `1px solid ${s.color}30`,
                    borderRadius: 5, padding: "5px 8px", display: "flex", gap: 6, alignItems: "flex-start",
                  }}>
                    <span style={{ fontSize: 11 }}>{s.icon}</span>
                    <div>
                      <div style={{ fontSize: 10, fontWeight: 700, color: s.color }}>{s.label}</div>
                      <div style={{ fontSize: 8, color: P.sub, lineHeight: 1.3 }}>{s.sub}</div>
                    </div>
                  </div>
                ))}
              </div>
              <Divider color={P.coord} label="synthesise into" />
              <div style={{ background: `${P.coord}10`, border: `1px solid ${P.coord}30`,
                borderRadius: 5, padding: "6px 8px", fontSize: 10, color: P.coord, fontWeight: 600 }}>
                WEEK_BRIEF — completion data · comments verbatim · energy signal ·
                avoidance patterns · anchor habits · constraints
              </div>
            </FlowBox>

            <Arrow color={P.coord} />

            {/* CHECKPOINT 1 */}
            <CheckpointBox n={1}
              title="Checkpoint 1 — Signal brief"
              detail="Coordinator presents: completion table with Prateek's verbatim comments, behavioural inferences, energy split, data quality flag. Prateek confirms or adds context. Mentors don't run until this is cleared." />

            <Arrow color={P.cp} />

            {/* PHASE 2 — MENTOR AGENTS */}
            <MentorCluster />

            <Arrow color={P.mentor} />

            {/* PHASE 3 */}
            <FlowBox icon="⚖️" title="Phase 3 — Conflict resolution" color={P.coord}
              subtitle="Coordinator reviews all MENTOR_REPORTs. Resolves conflicts before presenting anything.">
              <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginTop: 4 }}>
                {[
                  "Time budget check (3hr ceiling/day)",
                  "Slot conflict resolution",
                  "Cross-domain time-stacking",
                  "Round 2 agents if conflicts (max 1)",
                ].map(s => (
                  <div key={s} style={{
                    background: `${P.coord}10`, border: `1px solid ${P.coord}25`,
                    borderRadius: 4, padding: "3px 7px", fontSize: 9, color: P.sub,
                  }}>{s}</div>
                ))}
              </div>
            </FlowBox>

            <Arrow color={P.coord} />

            {/* CHECKPOINT 2 */}
            <CheckpointBox n={2}
              title="Checkpoint 2 — Plan approval"
              detail="Coordinator presents: Mon–Sun plan exactly as it will appear in Todoist, mentor concerns, one thing to protect, one thing to watch. Prateek approves or requests changes. One round only. Nothing is written until cleared." />

            <Arrow color={P.cp} />

            {/* PHASE 4 */}
            <FlowBox icon="✍️" title="Phase 4 — Write outputs" color={P.output}
              subtitle="All writes happen after Checkpoint 2 is cleared. Simultaneous where possible.">
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 4, marginTop: 4 }}>
                {[
                  { label: "Todoist", sub: "next week tasks with due dates", color: P.signal },
                  { label: "domain log.md ×N", sub: "append LOG_ENTRY verbatim", color: P.domain },
                  { label: "TRACKER.md", sub: "next week plan + completions para", color: P.user },
                  { label: "season_current.md", sub: "disruptions + track status", color: P.orch },
                  { label: "prateek.md", sub: "synthesise: auto-memory + mentors + execution", color: P.orch },
                ].map(w => (
                  <div key={w.label} style={{
                    background: `${w.color}0c`, border: `1px solid ${w.color}30`,
                    borderRadius: 5, padding: "5px 8px",
                  }}>
                    <div style={{ fontSize: 10, fontWeight: 700, color: w.color }}>→ {w.label}</div>
                    <div style={{ fontSize: 8, color: P.sub, marginTop: 1 }}>{w.sub}</div>
                  </div>
                ))}
              </div>
            </FlowBox>

            <Arrow color={P.output} />

            {/* PHASE 5 */}
            <FlowBox icon="✅" title="Phase 5 — Present to Prateek" color={P.green}
              subtitle="Clean phone-readable summary. No file paths. No implementation details.">
              <div style={{ display: "flex", gap: 4, flexWrap: "wrap", marginTop: 4 }}>
                {["Domain snapshot table", "Next week plan (Mon–Sun)", "One thing to protect",
                  "One thing to watch", "Season exit check (if <3 weeks to end)"].map(s => (
                  <span key={s} style={{
                    background: `${P.green}10`, border: `1px solid ${P.green}30`,
                    color: P.green, fontSize: 8, padding: "2px 7px", borderRadius: 10, fontWeight: 600,
                  }}>{s}</span>
                ))}
              </div>
            </FlowBox>
          </div>

          {/* ── RIGHT: file ecosystem ── */}
          <div style={{ position: "sticky", top: 20 }}>
            <div style={{ fontSize: 9, fontWeight: 800, color: P.sub, letterSpacing: 1.5,
              textTransform: "uppercase", marginBottom: 8, opacity: 0.7 }}>
              File Ecosystem
            </div>

            <FileLayer title="Live Signal" color={P.signal} files={[
              { name: "Todoist", sub: "tasks · comments · overdue", read: true, write: true },
            ]} />

            <FileLayer title="Cross-session" color={P.memory} files={[
              { name: "auto-memory/", sub: "all Claude sessions", read: true },
              { name: "MEMORY.md", sub: "index", read: true },
            ]} />

            <FileLayer title="Execution" color={P.user} files={[
              { name: "TRACKER.md", sub: "plans + completions archive", read: true, write: true },
            ]} />

            <FileLayer title="Orchestration (permanent)" color={P.orch} files={[
              { name: "PROTOCOLS.md", sub: "canonical protocols", read: true },
              { name: "prateek.md", sub: "behavioral profile", read: true, write: true },
              { name: "season_current.md", sub: "live season state", read: true, write: true },
              { name: "cross_domain.md", sub: "synergies + constraints", read: true },
              { name: "WIKI_BRIDGE.md", sub: "wiki protocol", read: true },
            ]} />

            <FileLayer title="Domain ×11" color={P.domain} files={[
              { name: "curriculum.md", sub: "expert plan", read: true, write: true },
              { name: "log.md", sub: "session history", read: true, write: true },
              { name: "intel.md", sub: "↑ written by Sat task", read: true },
            ]} />

            <FileLayer title="Knowledge Store" color="#10b981" files={[
              { name: "wiki/index.md", sub: "concept / entity / synthesis", read: true, write: true },
            ]} />

            <FileLayer title="Planning (frozen)" color={P.file} files={[
              { name: "Season1_90Day_Plan.md", sub: "charter — read only", read: true, flag: "FROZEN" },
              { name: "Prateek_Life_Plan.md", sub: "20yr vision", read: true },
            ]} />

            {/* scheduled tasks */}
            <div style={{
              background: P.card, border: `1px solid ${P.border}`,
              borderRadius: 6, padding: "8px 10px", marginTop: 0,
            }}>
              <div style={{ fontSize: 8, fontWeight: 800, color: P.sub, letterSpacing: 1.2,
                textTransform: "uppercase", marginBottom: 6 }}>Scheduled Tasks</div>
              <div style={{ fontSize: 9, marginBottom: 4 }}>
                <span style={{ color: P.domain, fontWeight: 700 }}>weekly-mentor-refresh</span>
                <span style={{ color: P.sub }}> · Sat 10pm</span>
                <Tag label="ACTIVE" color={P.green} />
                <div style={{ color: P.sub, fontSize: 8, marginTop: 2, paddingLeft: 8 }}>
                  writes intel.md ×11 via web research
                </div>
              </div>
              <div style={{ fontSize: 9 }}>
                <span style={{ color: P.file, fontWeight: 700 }}>prateek-weekly-review</span>
                <span style={{ color: P.sub }}> · was Sun 6pm</span>
                <Tag label="DISABLED" color={P.file} />
                <div style={{ color: P.sub, fontSize: 8, marginTop: 2, paddingLeft: 8 }}>
                  replaced by pull-based conversation trigger
                </div>
              </div>
            </div>

            {/* agent loop callout */}
            <div style={{
              marginTop: 12, background: `${P.mentor}0d`,
              border: `1px solid ${P.mentor}44`, borderRadius: 8, padding: "10px 12px",
            }}>
              <div style={{ fontSize: 10, fontWeight: 800, color: P.mentor, marginBottom: 6 }}>
                Agent Conversation Loop
              </div>
              <div style={{ fontSize: 9, color: P.sub, lineHeight: 1.7 }}>
                <div style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 4 }}>
                  <div style={{ width: 8, height: 8, borderRadius: "50%", background: P.coord, flexShrink: 0 }} />
                  <span><span style={{ color: P.coord }}>Coordinator</span> builds WEEK_BRIEF,
                  spawns mentors in parallel</span>
                </div>
                <div style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 4 }}>
                  <div style={{ width: 8, height: 8, borderRadius: "50%", background: P.mentor, flexShrink: 0 }} />
                  <span><span style={{ color: P.mentor }}>Mentor agents</span> run independently,
                  read own domain files, return reports</span>
                </div>
                <div style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 4 }}>
                  <div style={{ width: 8, height: 8, borderRadius: "50%", background: P.coord, flexShrink: 0 }} />
                  <span><span style={{ color: P.coord }}>Coordinator</span> synthesises,
                  resolves conflicts (max 1 extra round)</span>
                </div>
                <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
                  <div style={{ width: 8, height: 8, borderRadius: "50%", background: P.user, flexShrink: 0 }} />
                  <span><span style={{ color: P.user }}>Prateek</span> enters at 2 fixed points only.
                  All else is autonomous.</span>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
