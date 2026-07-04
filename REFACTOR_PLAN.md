# Eye of Syn — Architecture Refactor Plan

Living document. Tyroller-style refactor (lego bricks + thin glue, small managers,
code/data separation, deterministic ticks) prioritizing **maintainability and
extensibility** without wasting solo-dev time. Each phase is one ~2–4h session,
independently shippable and playtestable, committed separately so any phase can be
reverted in isolation.

**Decisions (locked):**
- **Global's end-state: Hybrid.** Global's API is FROZEN — never add new registries,
  helpers, preloads, or state. Existing call sites keep using Global indefinitely; files
  rewritten during this refactor and all NEW systems talk to specific modules directly.
  (Documented in README Architecture section.)
- **Budget: medium (~8–12 sessions).**
- **Reference regression level: Level0-2.**

**Hard constraints (README gotchas — never violate):**
- Compact registration arrays by building a NEW array with `is_instance_valid` filtering
  (template: `resetOcculumCount`). Never alias+append while iterating.
- Preserve the 2–4 physics-frame awaits before overlap queries after spawn.
- Purple/Green group set BEFORE `add_child`; collision layers 2/3/4/5/12/13 load-bearing.
- "Occulum" spelling intentional; demon names carry numeric suffixes.
- Dual-dimension sibling pairing + cull masks is THE core mechanic — never restructure.
- Restart re-enters `change_dual_scenes` — the hot path for freeze bugs.

---

## Status

| Phase | Commit | State |
|---|---|---|
| 0 — Bug fixes + guardrails | `82008d15` | DONE, baseline playtest passed |
| — Threshold inversion fix | `a0147c89` | DONE (found during Phase 0 verification) |
| 1 — PlayerHealth + kill manual `_ready` | `0eaf1f73` | DONE |
| — UiFx freed-meta fix | `73464ce3` | DONE (playtest fallout) |
| — Self-healing mower pool | `1b860327` | DONE (playtest fallout; culprit diagnostic armed) |
| — Mower dimension visibility | `d382df7c` | DONE (playtest fallout) |
| 2 — UI glue out of Global | `a6ea4570` | DONE |
| 3 — Buff targeting + Dim constants | (this commit) | DONE — awaiting buff-matrix playtest; dual-run safety net armed |
| 4 — SynergyDefinition resource | | pending |
| 5 — DemonDefinition catalog | | pending |
| 6 — Deterministic tick + swap rewrite | | pending |
| 7 — Cheap cleanups | | optional |

Open diagnostics: `lawnmower.gd._exit_tree` warning names whatever frees launched mowers
mid-session — remove once identified (quit-time warnings are normal teardown noise).

---

## Phase 0 — Bug fixes + guardrails (DONE — 82008d15)

1. `score_manager.gd`: `reset()`; completion-time thresholds restructured into arrays
   indexed by `SCORE_RANKS` (ranking previously compared against six never-assigned
   scalars — it had never worked).
2. `level_template.gd` `_ready()`: `ScoreManager.reset()` next to
   `Global.reset_all_variables()`.
3. `Global.reset_all_variables()`: also compact `all_demons`/`ui_layers`/`wave_previews`
   (new-array template via `compact_registrations()`); clear the three syn registries +
   six cached purple/green refs; reset `occulumCountVisual`, `hero_demon_summoned`,
   `ultimate_is_ready`.
4. `WaveManager._setup`: `is_connected` guard on lane-detector connect.
5. README: frozen-Global rule, per-frame update order, regression checklist.

**Validation:** restart ×3 from purple AND green pause → score 0, health full, single
mower launch per leak, no error spam; completion-time rank varies with the level's
exported thresholds. *(Passed. Follow-up: thresholds were inverted — fixed in a0147c89,
including style_screen's last-match-wins rank display → first-match elif.)*

## Phase 1 — PlayerHealth extraction + kill manual `_ready()` re-invocation (DONE — 0eaf1f73)

1. `_Utilities/Waves/PlayerHealth.gd` (`class_name PlayerHealth extends Node`):
   `max_health`, `current`, `health_changed`/`depleted` signals, `damage()`, `reset()`.
   Child of `WaveManager.tscn`; UILayers subscribe via `Global.wave_manager`.
2. `WaveManager`: `_setup` → public idempotent `setup_level()`;
   `game_controller.gd` calls `call_deferred("setup_level")` instead of `"_ready"`.
3. Lawnmowers pooled instead of `queue_free` at max distance (freed mowers were lost for
   every later level — real bug). *(Superseded by 1b860327: mowers are now their own
   scene `LawnMower.tscn`, recreated by name in `_ensure_lawn_mowers()` — self-healing
   against the still-unidentified external free. d382df7c stamps them with DIM_BITS so
   they render only in their own dimension.)*

**Validation:** health updates in both dimensions on leak; lose at 0; restart restores
full health + all six mowers; wave-0 preview/start button appear post-restart; restart
torture (checklist 7) incl. mashing restart against the `_is_transitioning` guard.

## Phase 2 — UI glue out of Global (DONE — a6ea4570)

1. `_UI/ui_fx.gd` (`class_name UiFx` statics): single home for the pulsing highlight
   that was **triplicated** (Global / ToolTips / DemonSelectionMenu). ToolTips + DSM keep
   public methods as one-line delegates passing their exported style (level scripts don't
   churn); direct `Global.*` glow callers updated to `UiFx.` (members deleted per frozen
   rule). *(Follow-up 73464ce3: fetch possibly-freed panel metas untyped + remove metas
   on removal — Global's copy had the guard, the copy taken as canonical didn't.)*
2. Codex navigation (`navigate_to_synergy` + six finish ladders + `split_capitals`)
   moved into `demon_lore_book_controller.gd`; Global keeps an 11-line handoff
   (`pending_codex_synergy`, `navigate_to_buff`, `register_demon_codex`).
3. Info-bar bodies: already thin delegates — nothing moved.
4. `#region` banners on the big contiguous blocks; `ultimate_is_ready` relocated to
   session flags. global.gd 1400 → 1147 lines.

**Validation:** tutorial highlights pulse/clear identically (levels 1, 2, 5, 7, 8); PiP
glow; synergy unlock → codex lands on correct page/tab for ≥5 pairs; zero behavior diff.

## Phase 3 — Exact-name buff targeting + `Dim` constants (DONE — playtest pending)

*Implementation notes:* `giveBuffTo` was a plain var (not @export) with the identical
full list on every demon — the "allow-list" was universal, so no scene edits were
needed and current behavior = "buff all six types, exclude Drones/Heart/EmptyDemon".
`get_demon_true_name()` coverage verified: six types override it; base returns ""
(never matches) for Heart/EmptyDemon/future demons — matching old behavior. The dead
SpinalOcculum/Wyrm special case (a `pass` with a TODO) was dropped. Collision-constant
conversion scoped to files this refactor touches (demon_base, BuffNodes, lawnmower) per
the hybrid rule — the ~18 zombie-side files migrate opportunistically.
`GameController.DIM_BITS` now references `Dim.DIM_BITS` (single source).

1. **Create `_Utilities/dim.gd`** (`class_name Dim`): `PURPLE`/`GREEN` StringNames,
   collision constants (`LAYER_PURPLE_DEMONS=2`, `LAYER_GREEN_DEMONS=3`,
   `LAYER_PURPLE_ZOMBIES=4`, `LAYER_GREEN_ZOMBIES=5`, `LAYER_PURPLE_BUFF=12`,
   `LAYER_GREEN_BUFF=13`), `DIM_BITS` (single source; `GameController.DIM_BITS`
   references it), `static of(node)`, `static other(c)`. Replace magic numbers at their
   use sites (grep `set_collision_layer_value` / `set_collision_mask_value`). Do NOT
   change which layers are set or group-before-add_child ordering.
2. **`BuffNodes.gd`**: `giveBuffTo` → `@export var give_buff_to: Array[StringName]` set
   per demon scene (defaults preserved); substring match at line 141
   (`demonActor in demonToBuff.name`) → exact match on `get_demon_true_name()`
   (digit-stripped; kills the Occulum ⊂ SpinalOcculum trap). Keep Drone exclusion +
   Purple/Green cross-checks exactly.
3. **Migration safety net:** for one playtest, compute BOTH old and new match and
   `push_warning` on disagreement; delete the old path after a silent full run.
4. Verify `get_demon_true_name()` exists on every demon that can occupy a zone
   (incl. EmptyDemon — confirm it can't false-match).

**Validation (HIGH risk — behavioral):** buff matrix spot-check — every demon type gives
AND receives once; Occulum-zone + SpinalOcculum occupant and inverse explicitly correct;
dual-run warning silent for a full Level0-2 playthrough; debuff on buffer death;
checklist items 1, 2 in full.

## Phase 4 — SynergyDefinition resource + unlock state (pending, 1–2 sessions)

1. `_Entities/Demons/Synergies/synergy_definition.gd` (`Resource`): `id: StringName`
   (existing key strings unchanged), `source_demon`, `target_demon`, `display_name`,
   `description_file`, `codex_page: StringName`, `codex_alt_index: int` (replaces the
   nav ladders moved in Phase 2).
2. `synergy_catalog.gd` + one `SynergyCatalog.tres` with 30 sub-resources.
3. `global.gd`: delete the 30 `is_*` bools + name vars + `all_demon_synergies` +
   `unlocked_demon_synergies_dict`; replace with preloaded catalog (data) +
   `unlocked_synergies: Dictionary` (runtime state) + `is_synergy_unlocked(id)`;
   rewrite `unlock_buff` against the catalog. **Grep all consumers first — that defines
   real scope.** Check whether unlocks persist to disk anywhere.
4. Codex: ladders + `split_capitals` → `catalog.get_by_id(id)` → page button →
   alt-index press (~15 lines replacing ~160).

**Validation:** synergy unlock fires notif; codex lands correctly for ≥5 pairs
(exhaustive transcription check of the six match-tables into the .tres); adding a NEW
synergy = one sub-resource, zero Global edits; checklist item 2.

## Phase 5 — DemonDefinition catalog (pending, 1 session)

1. `_Entities/Demons/Definitions/demon_definition.gd` (`Resource`): `id`,
   `display_name`, `scene: PackedScene`, `icon: Texture2D`, `base_cost: int`,
   `special_description_file`. Plus `DemonCatalog.tres` (all 7 demons).
2. `global.gd`: delete `_load_demon_costs` (instantiates every demon scene at menu
   `_ready` just to read one export), `demon_scenes`, `demon_costs`, icon preloads +
   description path vars; `get_demon_cost()` reads catalog. Occulum's +15/+25 scaling
   stays in `Occulum.gd`, reading `base_cost` from its definition.
3. `DemonSelectionMenu.gd`: read icons/costs/scenes from catalog. **Touch ONLY catalog
   reads** (751 lines / 35 Global refs — resist cleaning anything else).

**Validation:** identical menu icons/costs; Occulum +15/+25 scaling per dimension
unchanged; level load measurably faster; new demon = scene + one catalog entry, zero
Global edits; checklist item 1.

## Phase 6 — Deterministic tick + swap-ability state machine (pending, 2 sessions)

**6a — central tick order.** `Global._process` becomes the explicit conductor:
(1) zombies tick → (2) buff zones tick. Iterate `all_demons.duplicate()` with
`is_instance_valid`, call `demon.tick_buff(delta)`; demon_base forwards to BuffNodes.
BuffNodes `_process` body → `tick_buff(delta)` + `set_process(false)`. Gate `tick_buff`
behind a `buff_ready` flag set after demon_base's existing 2-physics-frame awaits.
Syn charges keep their own `_process` (already clean).

**6b — swap ability rewrite.** Port `syn_ability.gd`'s READY/ACTIVE/COOLDOWN accumulator
into `swap_ability.gd`. Delete both Timer nodes (also fixes `stop_ability_timer` children
accumulating every `begin()`). Freeze the public surface (`begin`, `stop`, hide/show,
`lock_unlock_swap_ability`, `reset_on_game_start`, `set_current_visibility_layer`,
`get_panel_container`, `game_start`) and semantics: early cancel → normal cooldown; full
duration → special (−2.5s); bar fills 0→100 during cooldown. The four subclasses need
zero edits. **Leave lightning_storm's await chains alone.**

**Validation (6a HIGH risk):** buff behavior unchanged after tick centralization (full
checklist item 2); mid-frame demon frees during the buff loop absorbed by
duplicate-array + is_instance_valid; pause early-return preserved. **(6b medium):** bar
behavior frame-identical (early cancel / full / lock / restart); no Timer children under
SwapAbility in the remote tree; checklist item 3 in full.

## Phase 7 — Cheap cleanups while the hood is open (optional, 1 session)

1. `DemonManager.gd`: `parentName == "Level0-1"` ladder → `@export var placement_bounds:
   Rect2` set per level scene (default = current else-branch).
2. `global.gd` syn registries: collapse three copy-pasted register/connect/deregister
   blocks into one generic pair-linker (public names stay). **Fix the README known
   issue:** tear down the cross-dimension connector on the surviving half when its
   partner dies.
3. Delete `canPlayLevelN` getter/setter boilerplate.

**Validation:** placement bounds identical per level (checklist 1); syn pair
link/connector behavior identical + connector dies with partner (checklist 4).

---

## Module placement (decided)

| Module | Form | Why |
|---|---|---|
| PlayerHealth | Node child of WaveManager.tscn | Session state w/ signals; found via `Global.wave_manager` |
| UiFx | `class_name` statics | Stateless; precedent: SoundEffect, ZombieRegistry |
| Dim | `class_name` consts | Must work in `@tool` scripts, no tree access |
| Synergy/Demon catalogs | `.tres` Resources, preloaded field | Data in Resources (WaveData precedent); unlock STATE stays in Global |
| Codex nav | Codex's own script | UI navigates itself |
| Registries/session/progression | Stay in Global (frozen API) | README-sanctioned locator; hybrid rule |
| New autoloads | **None** | Nothing needs another global lifecycle |

## Explicit skip list (agreed not worth solo-dev hours)

1. Four-registry Global split + forwarding facade — regions + extractions achieve it.
2. DimensionContext dependency injection — `Dim` consts + Global locator instead.
3. Per-unit ZombieStats/DemonStats `.tres` — `@export` on scenes already IS data separation.
4. ScoreRules.tres — named consts + `reset()` suffice until per-level tuning is real.
5. Sim/view separation — nothing demands it; dual-dimension must not be restructured.
6. lightning_storm await→scheduler — until a concrete bug.
7. DemonSelectionMenu general rehab — catalog reads + duplicate-helper deletion only.
8. Unit-test harness — the manual regression checklist is the honest solo equivalent.

## Regression checklist (reference level: Level0-2)

Run relevant items per phase; FULL run after phases touching restart, buff matching, or
tick order (1, 3, 6).

1. **Place:** each demon type in both dimensions; costs correct; Occulum +15/+25 scaling
   per dimension; mirror-cell blocker works.
2. **Buffs:** each demon gives + receives; SpinalOcculum ≠ Occulum matching both
   directions; debuff on buffer death.
3. **Swap:** ability fires before dimension flip; bar fill; early-cancel vs full-duration
   cooldowns; lock toggle; PiP mirrors inactive dimension.
4. **Syn:** cast both dimensions → pair links + connector; 4× recharge while other half
   deployed; cooldown starts at instance death; (post-Phase 7) connector dies with partner.
5. **Waves/health:** leak → ONE mower launch, mower renders only in its own dimension;
   health decrements both labels; lose at 0; early-wave call adds blood + score.
6. **Score:** completion-time rank varies with thresholds (SSS = tightest time); style
   points; synergy multiplier.
7. **Restart torture:** ×3 from purple pause, ×3 from green, once mid-wave with deployed
   syn + active swap + launched mower — no freeze, no error spam, score 0, health full,
   mowers restored, costs reset, no stale connectors.
8. **Progression:** advance level normally; unlock flags intact.

## Validation tooling

- Headless boot smoke test after every change set:
  `Godot_v4.6.2-stable_win64_console.exe --headless --path <proj> --quit-after 30`,
  grep output for `SCRIPT ERROR|Parse Error|Compile Error`. Run `--import` once per
  fresh worktree first (also after adding scripts/scenes, to register uids).
- `--check-only -s` is NOT usable here: autoloads/Dialogic aren't registered in that
  mode, so every Global-referencing script false-fails.
- In-game validation is Jason's manual pass per the checklist above.
