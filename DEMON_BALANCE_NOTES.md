# DEMON_BALANCE_NOTES.md: Eye of Syn

One reference for demon balance: base stats, core purpose, and all 30 synergies. Built 2026-10-20
from the demon scenes and scripts (`_Entities/Demons/**`), `Demon Synergies Sheet.xlsx` and the
in-game synergy text (`_Assets/Text/TextFiles/Synergies/{Receiver}{Giver}.txt`).
Zombies, waves and difficulty stay in `BALANCE_NOTES.md`.

## Source-of-truth rules (settled 2026-10-20)

- **Design intent = the sheet's `Stats` tab.** The `Synergies` tab is an earlier draft;
  `Level2Synergies` / `Level4Synergies` are old drafts and are ignored.
- **Base health = code.** The sheet's flat 60 is a placeholder.
- **Costs = code** (the sheet has Wyrm 175, Spinal 75, Maw 300).
- **Wasp counts = code:** 3 base, 5 with Occulum, 4 with Spinal. The sheet's "×N" wording is stale.
- **Hit-marking is fine.** For Wyrm ← Hive and Wyrm ← Maw, any zombie the shot *hits* carries
  the effect to its death, whatever kills it. Reword the sheet; keep the code.
- **Every other code vs. sheet difference is listed, not decided.** See the Open column and
  the [Open decisions](#open-decisions) checklist.

"Code" means the live values: each demon scene's root-node overrides, otherwise the script
defaults. No `DemonStats` config or `StatsSet` is assigned yet, so nothing else overrides them.

Mechanics the tables assume:
- A demon holds **one** buff at a time; the first buff zone that reaches it wins.
- Self-pairs (Crawler + Crawler, and so on) do nothing.
- The Wyrm Queen gives Wyrm buffs but can't receive any.

---

## 1. Base demons

| Demon | Cost | Health | Damage / output | Cadence / range | Ultimate (mana) | Core gameplay purpose |
|---|---|---|---|---|---|---|
| **Occulum** | 50, then +15 for each one placed (first 4), +25 after that | 125 | 25 blood per drop (auto-collects after 9 s at half value). +10 mana per drop | 1 drop / 33 s *(sheet: 25 per 31 s, open)* | The next drop is worth 100 | **Economy.** The only steady blood source. Fragile. |
| **Crawler** | 75 | 100 | 11 per web shot, every shot slows. +10 mana per shot | Every 1.8 s plus the animation (1.2× anim speed). Range 250 px, first target only | 8 volleys × 3 shots, 0.1 s apart | **Single-target ranged DPS plus slow.** Main lane shooter. |
| **Wyrm** | 125 | 100 | 14 piercing (−0.5 per extra zombie hit), bleed 1. +10 mana per shot | Every 3 s. Range 250 px | Beam: 125 dmg + 15 bleed, then a 2×-speed shot | **Piercing lane damage with bleed.** Answers groups. |
| **Spinal Occulum** | 50 | 800 | None. +10 mana per hit taken | Blocks the lane; slows on contact | Rib shield (absorbs 250) on demons in its rib area | **Wall / tank.** Stalls zombies and protects the back line. |
| **Hive** | 175 | 800 | 3 wasps, 7 dmg each per attack animation. Wasp: 100 HP, 150 speed, 20 px reach | Dead wasps respawn every 6 s. Detection range about 157 px | None | **Staller / swarm.** Wasps pin zombies in place and chip them. |
| **Maw** | 275 | 800 | Instakill with 3 tentacles. Each zombie costs 1+ tentacles; bosses are immune | 15 s digest per meal. Reach about 73 px. 2 cells wide | None | **Hard removal.** Deletes priority zombies on a long cooldown. |

The purposes are inferred from the code. Reword any that don't match your intent.

**Gaze of Baal (sorcery) multipliers:**

| Demon | Effect |
|---|---|
| Occulum | Blood 1.5× faster |
| Crawler, Wyrm | 2× damage |
| Spinal Occulum | Can't be killed |
| Hive | Wasps deal 3× damage, take half damage |
| Maw | Digests 2× faster |

---

## 2. Synergies (grouped by the demon that receives the buff)

Columns:
- **Intent**: the `Stats` tab.
- **Code**: what runs now, with numbers.
- **In-game text**: the `.txt` the codex shows.
- **Open**: differences still to decide. "None" means intent and code agree.

### Occulum receives (base 125 HP, 25 blood every 33 s)

| Giver | Intent (Stats tab) | Code | In-game text | Open |
|---|---|---|---|---|
| Crawler | On pickup, blood flies to the **nearest** zombie and damages and slows it. Faster blood | HP 375. Blood every 25 s. Flies to the **highest-HP** zombie in its AOE: 125 dmg + slow. Auto-collects at 10 s | "highest health enemy" | Targeting: nearest or highest HP |
| Spinal Occ. | Faster blood + heal-over-time AOE | HP 500. Heals demons in its zone 200 every 10 s. **Blood rate unchanged** | Matches intent | Faster blood missing |
| Wyrm | Higher-value blood at a slower rate; lane damage on pickup | HP 375. Blood every 40 s, worth 70. Pickup spawns 2 blood swords in the lane, 100 dmg each | Matches | None |
| Hive | Faster blood; pickup heals nearby allies | HP 375. Blood every 17 s. Pickup heals demons in its AOE +100 | Matches | None |
| Maw | More HP; higher-value blood at normal pace; instakills on cooldown; eating makes blood **instantly** | HP 600. Blood worth 100, every 33 s. Once per blood cycle, it eats the next zombie that attacks it; a 25 blood drops after a 5 s delay | Matches intent | "Instant" vs 5 s delay; it only eats attackers |

### Crawler receives (base 100 HP, 11 dmg, 250 px)

The Stats tab says **every buff adds +10 damage**. The code adds +10, except Occulum, which adds +20.

| Giver | Intent | Code | In-game text | Open |
|---|---|---|---|---|
| Occulum | Webbed zombies give (more) blood on death | **31 dmg (+20). Range 450.** Zombies it hits give +2 blood on death | "+blood on death, +range, +damage" | +20 vs +10; the range boost isn't in the Stats tab |
| Spinal Occ. | Shoots slower; more HP; shots knock back | 21 dmg. HP 650. Knockback 32 px. **Fire rate unchanged** | Matches | "Shoots slower" missing |
| Wyrm | Shots carry an AOE that **arcs blood-web lightning to adjacent lanes** | 21 dmg. Each shot carries a local lightning zone: 15 dmg. No arcing | "Lightning AOE; shoots slower" | Arcing missing; text says "slower" |
| Hive | Also shoots in adjacent lanes | 21 dmg + 2 extra shots, one lane up and one down | Matches | None |
| Maw | Periodically spawns a spiderling that runs down the lane | 21 dmg. Spiderling every 8 s (50 HP, 10 dmg every 3 s) | Matches | None |

### Wyrm receives (base 100 HP, 14 pierce + bleed 1, every 3 s, 250 px)

| Giver | Intent | Code | In-game text | Open |
|---|---|---|---|---|
| Occulum | Faster fire; auto-collecting blood on multi-hit | Range 450. Fires every 0.9 s. A shot that hits 5+ zombies drops a 2-blood auto-collect | Matches | The range boost isn't in the sheet |
| Crawler | Shots slow | Shots slow | Matches | None |
| Spinal Occ. | More HP; more bleed buildup/damage | HP 500. Bleed 1 → 9 | "More damage when attacked; more HP" | Text stale |
| Hive | Enemies the Wyrm hits spawn wasp drones on death | Range +100. A hit zombie spawns a stationary minion drone when it dies | "Increased range" | Text stale; reword the sheet "killed" → "hit" |
| Maw | The first enemy hit explodes in an AOE column on death | HP 400. Shot dmg 90. The first zombie each shot hits explodes on death: 75 AOE | "Close-up kills heal; more HP; a little more damage" | Text stale; the HP/damage boost isn't in the sheet; reword "killed" → "hit" |

### Spinal Occulum receives (base 800 HP)

Every buff also turns on **0.1 HP/s regen**. The sheet doesn't mention it (open).

| Giver | Intent | Code | In-game text | Open |
|---|---|---|---|---|
| Occulum | Makes blood when attacked. *Note: health-bond the Occulum (Spinal takes its damage first)* | HP 1000. **Blood rib** in front of the Occulum. 25 blood when hit (5 s cooldown) | "Shields the Occulum, blood when attacked, more HP" | Rib and HP not in the Stats tab; health-bond not built |
| Crawler | Slowing zone in front | HP 1100. Web slow zone | Matches | The HP boost isn't in the sheet |
| Wyrm | Blood swords rise from the ground in front: damage **+ armor strip** | HP 950. Spike rock: 34 on activation, then every 5 s, **but repeat hits deal 1** (bug, see section 4) | Matches, without the armor strip | Armor strip missing; spike bug |
| Hive | Silencing field in front | Silence field | Matches | None |
| Maw | Damages enemies that attack it; more HP | HP 1500. Each attacker takes 25 per hit | "Raises nearby demon damage; nearby deaths heal; more HP" | Text stale |

### Hive receives (base 3 wasps, 7 dmg, 100 HP, 6 s respawn)

| Giver | Intent | Code | In-game text | Open |
|---|---|---|---|---|
| Occulum | More wasps; wasps drop blood on death; faster respawn | **5 wasps** (kept). Respawn 3 s. 2-blood auto-collect when a wasp dies | "×2, wasps give blood on death" | Reword the sheet/text to "5 wasps" |
| Crawler | *Hive-killed enemies leave a temporary tile slow zone* | A dying **wasp** slows the zombie it was fighting | "Hive kills spawn a web slowing zone" | Code doesn't match intent (zombies already have an unused `make_spawn_slow_on_death` hook) |
| Spinal Occ. | More wasps; more HP | **4 wasps** (kept), wasp HP 200. The Hive's own HP is set to 800, **no change** | "×1, more HP" | The Hive HP buff does nothing; reword "×3" |
| Wyrm | Gains a Wyrm that fires a forward silencing beam, no bleed | Piercing beam every 3 s: 20 dmg, silences, no bleed, no slow | "Wasps spit blood forward on attack" | Text stale |
| Maw | Wasps explode on death | Each dead wasp leaves a bomb: 100 AOE after 0.3 s | "Heal over time; wasps ramp damage" | Text stale |

### Maw receives (base 800 HP, 15 s digest, 3 tentacles)

| Giver | Intent | Code | In-game text | Open |
|---|---|---|---|---|
| Occulum | Blood on digest | 10 blood per finished meal | Matches | None |
| Crawler | AOE slow on digest | A web ball lands 128 px ahead and slows its AOE | Matches | None |
| Spinal Occ. | More HP; heals on digest; digests faster | HP 1500. Heals 300 per meal. Digest 11 s | Matches | None |
| Wyrm | Armor-stripping lane damage in 3 lanes on digest | Digest 10 s. 3 blood swords, 100 dmg each. Armor strip is a TODO | "Maws digest faster" | Armor strip missing; faster digest isn't in the sheet; text stale |
| Hive | More range; periodically instakills groups | Range ×1.2. Every 5 s it drags down the densest of 6 zones | "Increased range" | Text incomplete |

---

## 3. Auxiliary units (not in the build menu)

| Unit | Key numbers | Role |
|---|---|---|
| Heart Demon | 2000 HP, 8-dmg shots. The Heart buff gives +400 HP and max HP | Not in DemonCatalog. Legacy |
| Hero demon (Syn Monolith) | Beat of Death: 12 dmg × 12 beats, 0.4 s apart. Lightning strike (3 shots). Revives demons | Double-click a demon to spawn it. It also summons a blood clone in the other dimension |
| Blood clone / Empty | The clone respawns after 45 s | Mirrors the hero's host demon in the opposite dimension |
| Wyrm Queen | Laser 50. Gives Wyrm buffs, receives none | Scripted ally |
| Spiderling / minion drone | 50 / 100 HP, 10 dmg every 3 s | Spawned by Maw → Crawler and Hive → Wyrm |

---

## 4. Code issues noticed (outside balance, recorded only)

- **Spinal ← Wyrm spikes:** `spike_rock.gd` `spike_attack()` calls `take_damage(spike_damage)` with one
  argument. That lands in `is_link_damage`, so every repeat spike deals the default 1 damage.
- **Hive ← Spinal health:** `hive_health_component.gd` sets health to 800 (the same as base) and never
  sets max health.
- **Unused exports:**
  - Crawler `lightning_projectile_damage`: the lightning zone uses the projectile's own 15.
  - Occulum `hive_burst_heal_amount`: `Blood.gd` hardcodes +100.
  - Blood `default_auto_pickup_wait_time`: the scene timer is 9 s.
- **Occulum heal zone:** never removes demons that leave it.
- **Corrections to `BALANCE_NOTES.md` section 3:** that file wasn't edited, so these still read wrong there.
  - It lists wasps at 75 HP; the Hive sets them to 100.
  - It lists Maw digest at 5 s (Wyrm) and 9 s (Spinal); the scene overrides these to 10 s and 11 s.

---

## Open decisions

- [ ] Occulum blood rate: 33 s (code) or 31 s (sheet)
- [ ] Occulum ← Crawler: blood targets the nearest zombie or the highest-HP one
- [ ] Occulum ← Spinal: add "faster blood"?
- [ ] Occulum ← Maw: instant blood vs 5 s delay; eat only attackers, or anything in range?
- [ ] Crawler ← Occulum: +20 dmg and 450 range, or +10 only?
- [ ] Crawler ← Spinal: add "shoots slower"?
- [ ] Crawler ← Wyrm: lightning arcing to adjacent lanes?
- [ ] Wyrm ← Occulum: keep the range boost?
- [ ] Wyrm ← Maw: keep the HP 400 / 90 dmg boost?
- [ ] Spinal: keep the 0.1 HP/s regen on every buff?
- [ ] Spinal ← Occulum: rib + HP boost vs health-bond
- [ ] Spinal ← Crawler: keep the HP boost?
- [ ] Spinal ← Wyrm: add armor strip (and fix the spike bug)
- [ ] Hive ← Crawler: wasp-death slow vs a slow zone where Hive kills die
- [ ] Hive ← Spinal: real Hive HP boost?
- [ ] Maw ← Wyrm: add armor strip; keep the faster digest?
- [ ] Rewrite stale in-game text from the final intent: Wyrm ← Spinal/Hive/Maw, Spinal ← Maw,
      Hive ← Occulum/Spinal/Wyrm/Maw, Maw ← Wyrm/Hive, Crawler ← Wyrm
- [ ] Update the sheet: costs, health, wasp counts, "killed" → "hit"
