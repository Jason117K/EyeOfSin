# BALANCE_NOTES.md — Eye of Syn

How the game is balanced, as of 2026-10-12. Use this when designing waves or tuning units.
Stat values come from the code and scenes. Design intent comes from the designer and from
the "Enemy Design" doc. Where those two disagreed, the designer's call is recorded here.

---

## 1. How waves work (the parts that matter for balance)

- **Lanes:** each dimension (Purple and Green) has 7 `ZombieSpawner`s. Spawner N is lane N,
  counted top to bottom. A wave's real size is the sum across all 14 spawners.
- **Spawn pacing within a wave:** the first zombie in a lane appears after 0.1–2.6 s, then one
  every 1.1–1.9 s (about 1.5 s on average). The order is shuffled unless `is_random` is off.
  A lane with *n* zombies therefore takes about 1.5·*n* s to empty, so the same total spread
  over more lanes arrives faster and hits harder.
- **Wave count and timing:** total waves = number of wave timers + 1. The timers come from the
  level scene's `wave2StartTime … wave6StartTime`. Despite the names these are **gaps between
  one wave starting and the next**, not absolute times, so the maximum is 6 waves. The next
  wave's preview appears 25 s before it starts.
- **Calling early:** good players will do this. It gives +25 blood and score on top of the
  normal +25 blood that every wave after the first gives. Gaps mostly set the pace for
  average players; for good players, the wave contents are the main difficulty lever.
- **Source of truth (Level 10 onwards):** each spawner's `waves` array in the level `.tscn`,
  edited through the **WaveTableHost** (Wave Table Editor plugin). From Level 10 on, level
  scripts must **not** call `set_waves_from_dicts()`, because that overwrites the scene data
  at runtime. Levels 1–9 still set their waves in code.
- **Wave presets:** the WaveTableHost inspector can save the open scene's tables plus its
  `wave2StartTime…wave6StartTime` as a named preset, and load one back as a single undo
  step. Presets live in `_Stages/<Level>/WavePresets/<name>/<scene>.json`, one file per
  dimension, so load the same name in both scenes. They're snapshots; **save the scene
  after loading**, because the scene is still what the game plays. The folder has a
  `.gdignore`, so presets don't show in the FileSystem dock and aren't exported. Level 10
  has `L10 v1` (the 2026-10-12 rebuild) and `L10 original` (before it).
- **Every spawner needs exactly as many `waves` entries as the level has waves** (pad with
  empty WaveData). A spawner only reports "done" after its own last entry, so one with 0
  entries stops the level from ever ending, and one with extra entries does the same.
- **Danger score:** a wave's danger = Σ count × `ZombieRegistry.DANGER_SCORES[type]`. It's a
  **guideline, not a rule**.

## 2. Zombies

Speed is in px/s. Reborn (8) is the slowest. The design doc's scale is Low → Medium → High,
and the step from Medium to High is bigger than the step from Low to Medium.

| Zombie | HP | Speed | Damage to demons | Danger | Design role |
|---|---|---|---|---|---|
| Reborn | 50 | 8 (Low) | 10/s | 2 | Fodder and training wheels; later used in large numbers for a sense of scale |
| Severed | 170 | 11 (Low) | 30/s | 5 | The upgraded foot soldier; the horde threat once defenses are built up |
| Unhallower | 600 + armor | 8 (Low) | 120 per hit every 2 s (60/s) | 50 | Slow tank that deals massive damage to demons; needs burst |
| Amalgam | 300, then a 150 HP second life | 16 (Med) | 40/s | 25 | Tanky but faster; its "armor" is the second life |
| Reanimator | 375 | 14 (Low) | 50 per hit every 2 s (25/s) | 100 | Summoner; overwhelms you over time if left alone |
| Wretch (summoned only) | 30 | 18 (Med) | none | — | Flies over demons, so stallers do nothing; only threat is reaching the end |
| Sundered | 200 | 21 (High) | 33/s | 25 | Sprinter that vaults over defenses; must be killed fast |
| Erupter | 60 | 48 (High) | 1000 to every demon in its blast | 50 | Suicide bomber that counters stallers ("walnuts") |
| Flesheater | 450 | 16 (Med) | 60/s | 150 | The apex threat; the player should feel threatened. **Not playtested yet.** |
| Buffer | 76 | 10 (Low) | 33/s | 50 | Makes everything near it more dangerous; must be dealt with quickly. Its slow speed offsets the danger. |
| Rohan | 1000 + armor | 8 | 100 | 1000 | Boss, only in specific levels |

The Ranged Zombie in the design doc is not implemented; ignore it.

### Special mechanics (as the code has them)
- **Armor** (Unhallower, Rohan): hits of 10 or more lose 5 damage; smaller hits are halved.
  **Piercing hits ignore armor completely.**
- **Amalgam second life:** at 0 HP it turns into a Severed-style body with 150 HP. A Maw kill
  or silence skips the second life. Piercing hits deal **double** damage to it.
- **Health regen** (Amalgam 3 per 2 s, Reanimator 5 per 2 s, Flesheater 7 per 2 s, so
  3.5 HP/s): it only ticks after 2 s without taking damage, because any hit resets the timer.
  Bleed ticks every second, so **damage over time switches regen off completely**. That's the
  doc's "D.O.T. counters regen" working as intended.
- **Reanimator:** every 12 s it summons up to 6 Wretches around itself (fewer when it's in an
  edge lane).
- **Sundered:** vaults about 110 px (roughly 3.4 tiles) over the first demon it meets, once.
- **Erupter:** explodes on first contact with a demon. The blast covers about 147 × 31 px
  (roughly 4.5 tiles of its lane) and deals 1000 damage to every demon in it.
- **Buffer:** every 7 s it stops and buffs the zombies around it with +50% damage and +25%
  speed. Each zombie can only be buffed once.
- **Silence** (from the SpinalOcculum + Hive synergy only): halves zombie damage, stops
  Reanimator summons, stops the Sundered vault, cuts the Erupter blast to 0, and skips the
  Amalgam's second life.
- **Slow:** each Crawler hit drops the zombie to 60% speed for about 10 s, and repeated hits
  stack the duration. SpinalOcculum slows anything that touches it.

## 3. Demons (player toolkit)

| Demon | Cost | HP | What it does | Role and counters it provides |
|---|---|---|---|---|
| Crawler | 75 | 100 | One 11-damage shot about every 2 s; slows. Armored targets only take 6. | Main single-target damage plus slow. Its buffs push stalling/slowing. |
| Occulum | 50, rising per copy | 125 | 25 blood every 33 s | Economy. Its buffs add blood production; some heal. |
| SpinalOcculum | 50 | 800 | Slows on contact | Main staller. Buffed by: Crawler → web slow; Wyrm → spikes; **Hive → silence field**; Maw → lightning; Occulum → blood rib. |
| Wyrm | 125 | 100 | Piercing blood shot every 3 s: 14 damage, 0.5 less per extra zombie hit, plus bleed | AOE and damage over time. **Ignores armor, hits Amalgams twice, switches off regen.** |
| Hive | 175 | 800 | 3 wasps (75 HP, 7 damage/s), respawn every 6 s; buffs raise the count to 4–5 | Stall/damage hybrid; handles crowds |
| Maw | 275 | 800 | Kills any zombie outright, then digests for 15 s | Burst; glass cannon. Removes the Amalgam second life. |

Player abilities from Level 6 on: Lightning Strike (Syn) and Lightning Storm (Swap). The
Ultimate is enabled from Level 7. Heart, Hero and Portal are out of scope for wave design.

### Counter cheat-sheet
| Zombie | What beats it | What doesn't |
|---|---|---|
| Reborn / Severed | Any steady damage; AOE (Wyrm) for big groups | — |
| Unhallower | Maw; Wyrm (pierce ignores armor) | Crawler chip damage (6 per hit); bleed (halved) |
| Amalgam | Wyrm (double damage), Maw, silence; bleed stops its regen | Low single-target damage spread over two lives |
| Reanimator | Bleed (stops regen) plus focused damage; silence stops summons | Leaving it alive (Wretch snowball) |
| Wretch | AOE, slow | Stallers (it flies over them) |
| Sundered | Slow plus fast kill; silence stops the vault | A single blocking staller |
| Erupter | Kill or slow before it reaches you (only 60 HP); silence | Clustered demons and stallers in its lane |
| Flesheater | Slow, bleed (stops regen), AOE, Maw | Sustained low damage that lets it regenerate |
| Buffer | Focus it down early (76 HP) | Ignoring it inside a pack |

Silence is gated behind the SpinalOcculum + Hive synergy. So in levels without the Hive, the
zombies that are weak to silence (Reanimator, Erupter, Sundered, Amalgam, Flesheater) are
noticeably stronger.

## 4. Difficulty calibration

Designer ratings (1 easiest – 5 hardest), made after the 2026-10-12 balancing pass, **without
Hive and Maw**:

| Level | Rating | Notes |
|---|---|---|
| 4 | 1 | Easy, lots of leeway |
| 6 | 2 | Need to be more active |
| 7 | 4 | Hard mostly because of its rule that zombies can't pass a line in each dimension |
| 8 | 5 | The hardest level; frequent fails |

**Ignore Levels 5 and 9** for calibration; they're exceptions.

### Reference numbers (both dimensions combined)
| Level | Starting blood | Gaps (s) | Danger per wave | Zombies per wave | Lanes per wave (per dimension) | Total danger | Peak pressure* |
|---|---|---|---|---|---|---|---|
| 4 | 300 | 65 / 90 / 105 | 140 · 320 · 486 · 1301 | 16 · 40 · 72 · 65 | 2 · 3 · 5 · 7 | 2,247 | 278 |
| 6 | 350 | 70 / 90 / 100 / 105 | 188 · 164 · 472 · 1107 · 1448 | 39 · 58 · 59 · 98 · 110 | 2 · 3 · 5 · 7 · 7 | 3,379 | 633 |
| 7 | 400 | 70 / 100 / 105 / 108 | 96 · 240 · 445 · 1016 · 1810 | 36 · 8 · 21 · 38 · 56 | 2 · 3 · 4 · 7 · 7 | 3,607 | 564 |
| 8 | 400 | 78 / 96 / 105 / 108 | 133 · 358 · 980 · 1290 · 1857 | 41 · 43 · 49 · 55 · 87 | 2 · 4 · 6–7 · 7 · 7 | 4,618 | 717 |

\*Peak pressure = a wave's danger ÷ the gap before the next wave, per minute (excluding the
final wave).

### Patterns to keep
- **Lane ramp-up (required):** start with few lanes and ramp up to all 7. In every reference
  level the lanes open in the same order:
  - Wave 1: Purple uses the inner lanes **3 and 5**; Green uses the edge lanes **1 and 7**.
  - Wave 2: both add the centre lane, **4**.
  - Wave 3: Purple fills **2–6**; Green uses **1, 2, 4, 6, 7**.
  - Wave 4 onwards: all 7 lanes.

  Opening lanes faster is one of the things that makes Level 8 a 5.
- **Gaps** start at 65–78 s and grow to 105–110 s.
- **How danger grows:** the first wave is about 100–190, then it roughly doubles each wave.
  The final wave is about 1,300–1,860, which is roughly 100–200 per lane per dimension.
  Higher ratings come from **heavier middle waves** (Level 8's wave 3 is 980; Level 6's is 472).
- **Two kinds of wave:**
  - *Fodder:* many Reborn and Severed, trickling out over 15–30 s per lane (Level 6).
  - *Elite:* a few heavy zombies that all arrive in under 10 s (Level 7).

  Level 8 mixes them: elites in Purple, swarms in Green.
- **The dimensions carry about the same danger**, but use different lanes early on.

### What the danger score misses
- Wretches summoned by a Reanimator aren't counted.
- Buffer's boost to other zombies isn't counted.
- How zombies are spread across lanes (concentration vs. spread).
- How the danger is split between Purple and Green.
- Level-specific rules (like Level 7's line).
- What the player has available. Hive and Maw sharply reduce the threat from zombies that
  are weak to silence or burst.

## 5. Upcoming levels

| Level | Demons available | Starting blood | Status |
|---|---|---|---|
| 10 | Crawler, Occulum, SpinalOcculum, Wyrm (same as the Level 7/8 ratings), **plus pre-placed Hives** (see below) | 500 | **Rebuilt 2026-10-12** (target rating 3, 5 waves); see §5.1. Awaiting playtest. |
| 11 | Same + Hive (silence becomes available) | 500 | Placeholder copy of Level 9's waves, set in code, using default gaps |
| 12 | Same + Maw | 500 | Placeholder copy of Level 9's waves, set in code, using default gaps |
| 13 | — | — | Not being worked on yet |

**Level 10's pre-placed Hives (kept on purpose):** the level scripts place Hives at the start:
Purple lane 4, Green lanes 1 and 7. The Hive button stays hidden, so the player can't build
more, but a SpinalOcculum next to one gives a silence field. Those three lanes can therefore
handle silence-weak zombies (Reanimator, Erupter, Sundered, Amalgam, Flesheater) better than
the rest; design Level 10's waves with that in mind.

### 5.1 Level 10 (rebuilt 2026-10-12, awaiting playtest)

**Brief:** rating 3; 5 waves; many high-HP zombies across many lanes at once; Erupter debuts
in waves 4–5. Allowed types: Unhallower, Reanimator, Erupter, Amalgam, Buffer, Sundered (no
Reborn or Severed). Starting blood 500 per dimension. Lane 1 is random now (the fixed order
was unintended).

**Lane order (Level 10's own, differs from the §4 ramp):**
- Wave 1: Purple 2 and 6; Green 3 and 4.
- Wave 2: Purple adds 1 and 7; Green adds 5 and 6.
- Wave 3: Purple adds 3 and 4; Green adds 1 and 2.
- Wave 4 onwards: all 7.

**Gaps:** 75 / 95 / 105 / 110 s (`wave2StartTime`–`wave5StartTime` on `Level10.tscn`;
`level10.gd` passes 4 delays).

"—" = lane closed. **H** = lane with a pre-placed Hive.

**Purple**
| Lane | W1 | W2 | W3 | W4 | W5 |
|---|---|---|---|---|---|
| 1 | — | Amalgam, Sundered | Unhallower | Unhallower, Sundered | Erupter, Unhallower, Buffer |
| 2 | Amalgam, Sundered | Unhallower | 2 Amalgam | Erupter, 2 Amalgam | 3 Amalgam |
| 3 | — | — | Amalgam, Sundered | 2 Amalgam, Sundered | Reanimator, Amalgam |
| 4 H | — | — | Reanimator | Erupter, Amalgam, Sundered | 2 Erupter, Amalgam |
| 5 | — | — | — | 2 Amalgam | Unhallower, 2 Amalgam |
| 6 | Amalgam, Sundered | 2 Amalgam | 2 Amalgam, Sundered | Reanimator | Erupter, 2 Amalgam |
| 7 | — | Amalgam | Unhallower | Unhallower, Amalgam | Reanimator, Sundered |
| Danger | 100 | 175 | 375 | 575 | 800 |

**Green**
| Lane | W1 | W2 | W3 | W4 | W5 |
|---|---|---|---|---|---|
| 1 H | — | — | Reanimator | Erupter, 2 Amalgam | 2 Erupter, Amalgam |
| 2 | — | — | Amalgam, Sundered | Unhallower, Amalgam | Reanimator, Amalgam |
| 3 | 2 Amalgam | 2 Amalgam | Unhallower | Reanimator | Erupter, Unhallower, Buffer |
| 4 | 2 Amalgam | Unhallower | 2 Amalgam | 2 Amalgam, Sundered | 3 Amalgam |
| 5 | — | Amalgam, Sundered | 2 Amalgam, Sundered | Erupter, Amalgam, Sundered | Erupter, 2 Amalgam |
| 6 | — | Amalgam | Unhallower | Unhallower, Sundered | Reanimator, Sundered |
| 7 H | — | — | — | 2 Amalgam | Unhallower, 2 Amalgam |
| Danger | 100 | 175 | 375 | 575 | 800 |

**Totals (both dimensions):** danger 200 · 350 · 750 · 1,150 · 1,600 = **4,050**; HP 3.1k ·
5.2k · 8.5k · 11.8k · 13.0k = 41.6k; zombies 8 · 12 · 20 · 32 · 38; peak pressure 627.
For comparison: Level 6 = 3,379 danger / 51k HP; Level 8 = 4,618 / 60k.

**Design intent:**
- Wide, not deep: 1–3 heavies in every open lane, so each lane empties in about 5 s and all
  lanes hit together. Amalgam is the backbone (58 in total).
- The lane ramp is as fast as Level 8's, so waves 2–3 are lighter than Level 8's.
- Hive lanes open with a lone Reanimator (W3). W4 puts an Erupter in each open Hive lane
  (Purple 4, Green 1): it kills the Hive unless it's silenced. That's the debut lesson. From
  W4 on, Reanimators go into non-Hive lanes.
- W5 climax: one Erupter + Unhallower + Buffer lane per dimension.
- The current scores underrate Amalgam. With the §6 suggested scores, Level 10 ≈ 4,980 vs
  Level 8 ≈ 4,910. That's offset by +100 blood per dimension, 3 free Hives, 30% less HP than
  Level 8, and Wyrm's double damage to Amalgams. Expected to play as 3 to 3.5.
- **Levers if it plays too hard, in order:** swap W4/W5 Amalgams for Sundered (same score,
  250 less HP each); drop the two W5 Buffers; add 10 s to gaps 3 and 4.
- The first Erupter spawn shows the new-zombie notification (`show_unlock_zombie_button` in
  both Level 10 scripts handles "Erupter").

## 6. Suggested danger values (parked)

The current `DANGER_SCORES` are in use. These suggestions are saved for later:

| Type | Current | Suggested | Reason |
|---|---|---|---|
| Severed | 5 | 7 | 3.4× Reborn's HP and 3× its damage, but only 2.5× its score |
| Amalgam | 25 | 40 | 450 HP across two lives, regen, double Reborn's speed |
| Reanimator | 100 | 70 | Level 4's final wave is about 61% Reanimator danger, yet Level 4 is rated the easiest |
| Erupter | 50 | 75 | One blast can wipe out several demons (low confidence; not in any rated level) |
| Flesheater | 150 | 100 | Now medium speed; roughly an Unhallower without armor but with regen. Re-check after playtesting. |
| Buffer | 50 | 35 | Fragile and slow; its threat comes from neighbours that are already scored |

Reborn 2, Unhallower 50, Sundered 25 and Rohan 1000 look right as they are.

## 7. Change log
- 2026-10-12 — Flesheater: speed 32 → 16 (Medium); health regen turned on at 7 HP every 2 s
  (3.5 HP/s).
- 2026-10-12 — Level 10: pre-placed Hives confirmed as intended; lane 1's fixed spawn order
  confirmed as unintended.
- 2026-10-12 — Level 10 rebuilt: 5 waves, gaps 75/95/105/110, 500 starting blood, new lane
  order, lane 1 randomized, Erupter notification (§5.1).
