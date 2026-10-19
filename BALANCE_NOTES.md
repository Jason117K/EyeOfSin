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
  has `Level 10 v1` (the 2026-10-12 rebuild) and `L10 original` (before it).
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
| Ranged | 250 (regen 2 HP/s) | 16 (Med) | 75 per shot, 1 shot/s, from about 3 tiles away (75/s) | 100 | Pressure unit: wrecks defenses from out of melee reach (Maw, stallers). Medium health but the quickest-restarting regen. **Not playtested yet.** |
| Tank | 2000 + armor | 8 (Low) | 500 per hit, about 1 hit/s | 400 | The highest-HP unit in the game: lumbers in, kills almost any demon in 1–2 hits, and launches a Minion past your front line every 5 s. A Maw can't eat it. **Not playtested yet.** |
| Minion ("Urchin"; launched by Tanks, can also be placed in waves) | 60 | 14 (Low–Med) | 50/s | 5 | Fragile harasser that lands *behind* the demon its Tank is attacking, then chews into the back line |
| Rohan | 1000 + armor | 8 | 100 | 1000 | Boss, only in specific levels |
| Act 2 Boss (`Act2Boss`) | Phase 1 1500, phase 2 1000 *per twin*, phase 3 1500 *per twin* (placeholders) | 8 / 10 / 6 | Two melee attacks per phase: 100 or 200, 75 or 150, 150 or 300 (placeholders) | 1000 | Three-phase boss that splits into twins. **Not playtested yet.** |
| Argus, Act 3 Boss (`Argus`) | 3000, **one pool shared** by both dimensions (placeholder) | 10 until planted | none (never attacks) | 1000 | Stands in both dimensions; immune in a dimension while its Herald lives. **Not playtested yet.** |
| Herald (spawned by Argus) | 800 (placeholder) | 8 | 60 (placeholder) | — | Shields Argus; reaching the house loses the level |

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
- **Ranged** (`_Entities/Zombies/_RangedZombie/`):
  - **Range and shots:** its attack ray reaches 101 px (about 3 tiles; melee zombies reach
    13–20 px), so it stops about 3 tiles short of the first demon in its lane. The first
    shot fires after 0.67 s, then one every 1 s. Each web ball deals 75 damage, flies at
    325 px/s and hits the first same-dimension demon it touches (portals and mirror
    blockers are skipped).
  - **What it dodges:** it never makes contact. The Maw's 73 px reach only catches it as it
    walks past in a neighbouring lane. SpinalOcculum's contact slow and the on-hit
    reflects (Spinal + Wyrm spikes, Maw lightning) never trigger.
  - **Regen:** 2 HP every 1 s. Any hit resets the timer, but it needs only 1 s without
    damage (others need 2 s), so it heals between slow hits such as a lone Crawler's.
    Bleed (1 s ticks) still switches it off.
  - **Silence** halves its shot damage.
  - **Not wired for a debut yet:**
    - `Global.zombie_notif_icons` has no `"Ranged"` key, so a level that shows its unlock
      button would error. `Global.ranged_icon` exists.
    - There's no `ZombieDescriptions` text and no tutorial demo scene (the
      `lancer_zombie_demo` uses the Sundered sprite).
    - Its special description is a one-line stub.
- **Tank** (`_Entities/Zombies/_Tank/`):
  - **Damage:** 500 per hit; the first hit lands 0.5 s after it reaches a demon, then one
    per second. A Crawler, Occulum or Wyrm dies in one hit. An 800 HP SpinalOcculum, Hive
    or Maw dies in two (about 1.5 s), so stallers barely delay it.
  - **Armor:** 2000 HP with armor. A Crawler hit does 6. Wyrm's piercing hits ignore the
    armor.
  - **Maw:** its `charge_cost` is 9, more than a Maw's 3 tentacles, so a Maw can **never**
    eat it. The Maw's tentacles go to its Minions instead.
  - **Minion launches:** it launches its first Minion 3 s after spawning, then one every
    5 s (`SummonComponent`). It stops for the launch animation, and keeps launching while
    it's attacking.
    - Each Minion appears about 47 px (about 1.5 tiles) ahead of the Tank. When the Tank
      is chewing on a demon, that's roughly a tile *past* that demon, behind your front
      line.
    - A Tank crossing the whole lane (about 90 s at 8 px/s, more with stops) launches 15+
      Minions. They aren't counted in its danger score, just like Wretches.
  - **Silence** stops the launches and halves its hit to 250.
- **Minion** (`_Entities/Zombies/_MinionZombie/`, shown in game as "Urchin"):
  - **Stats:** 60 HP, speed 14, one 50-damage bite per second (melee, 14 px reach). No
    regen, no armor. Its `charge_cost` is 1, so a Maw eats it in one tentacle.
  - **Scene data:** its scene saves about 19 properties as `null`. Godot falls back to the
    script defaults, so the numbers above are what actually loads (checked headless).
- **Not wired for a debut yet:**
  - **Tank:** has an icon and a `"Tank"` entry in `Global.zombie_notif_icons`. There's no
    `ZombieDescriptions` text or tutorial demo, and its special description is a one-line
    stub.
  - **Minion:** has no `"Minion"` entry in `Global.zombie_notif_icons` and no icon image
    (only sprite sheets). `minion_zombie.gd` returns `Global.minion_icon`, which doesn't
    exist, so **clicking a Minion in game errors** when the info bar asks for its icon.
- **Act 2 Boss** (`_Entities/Zombies/_Act2Boss/act2_boss_zombie.gd`, built 2026-10-19):
  - **Attacks:** every phase walks the lane and picks one of its two melee attacks at
    random (`Attack_PhaseN` / `_Alt`). Each attack lands on a set frame for its own
    damage.
  - **Phase 1 at 0 HP:** it plays `death_phase_1` (untouchable), becomes phase 2, and
    spawns a phase-2 **twin** in the other dimension at the same spot.
  - **Phase 2 at 0 HP:** a twin freezes on the first frame of `death_phase_2` for
    `twin_wait_time` (10 s).
    - If the other twin falls inside that window, both play `death_phase_2` and become
      phase 3 together.
    - Otherwise the downed twin revives at full phase-2 health.
  - **Phase 3 at 0 HP:** a real death; the boss is freed after `death_phase_3`.
  - **Per-phase inspector groups:** health, speed, sprite / ray / fire / Syn-mark
    positions, and each attack's damage and hit frame. Each phase has its own hurtbox.
  - **Immunities:** a Maw can't eat it (`charge_cost` 9), and Lucretia's grasp can't flip
    it. Silence halves its damage.
  - `bloodWorth` would pay out at every phase's zero-health moment.
- **Argus, Act 3 Boss** (`_Entities/Zombies/_Act3Boss/argus_boss.gd` +
  `_HeraldZombie/herald_zombie.gd`, built 2026-10-19):
  - **Arrival:** placed in one spawner. That instance is the *original*: it spawns a *copy*
    at the same spot in the other dimension, sharing its health component (one pool, each
    in its dimension's colour), plus two Heralds in Green lane 2 and Purple lane 7.
  - **Movement:** Argus walks `walk_distance` (250 px) from his spawn point, then stands
    playing `Idle`. He never attacks.
  - **Immunity:** he's immune in a dimension while its Herald is alive.
    - **One Herald down:** vulnerable in its dimension for `herald_down_time` (8 s). Then
      the Herald revives at full health where it fell (its death animation played in
      reverse).
    - **Other Herald down inside that window:** both stay down for `both_down_time` (15 s),
      and Argus is vulnerable in both dimensions.
  - **What can't hurt him:** hits and bleed only land while vulnerable. Mowers and direct
    `die()` calls can't kill Argus while he has health left. Neither Argus nor the Heralds
    can be eaten by a Maw (`charge_cost` 9) or flipped by Lucretia.
  - **A Herald reaching the house** calls `Global.lose_game()`.
  - **At 0 health:** both Argus instances fade out and the Heralds die for good, so the
    level can end.
  - **Placeholders:** name, description and icon (Rohan's).
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
| Maw | 275 | 800 | 3 tentacles (every zombie costs 1) grab and kill outright within 73 px (about 2 lanes either side), then each digests for 15 s (5 s with a Wyrm buff, 9 s with a SpinalOcculum buff). An Erupter it grabs is eaten without exploding. | Burst; glass cannon. Removes the Amalgam second life. |

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
| Tank | Wyrm (pierce ignores armor) plus lots of focused damage from range; silence (stops launches, halves its hits); slows; cheap demons thrown in its path to buy time | Maw (can't eat it); stallers (dead in 2 hits); Crawler chip (6 per hit); leaving it alive (endless Minions) |
| Minion | Any damage (60 HP); Wyrm AOE; Hive wasps; a back line that can fight, since they land behind the front | Defending only the front line; Maw tentacles wasted on them while the Tank closes in |
| Ranged | Damage that reaches 3+ tiles: Crawlers, Wyrm (bleed also stops its regen), Hive wasps; cheap or tough demons up front to soak shots while it's killed | Maw (it fires from outside the reach); SpinalOcculum's contact slow; slow chip damage it can regen through |

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
| 11 | Same + Hive (silence becomes available) + Portal, **plus pre-placed Maws** | 500 | **Rebuilt 2026-10-15** (target rating 4, 5 waves); see §5.2. Awaiting playtest. |
| 12 | Same + Maw (Crawler, Occulum, SpinalOcculum, Wyrm, Hive, Maw, Portal) | 500 | **Rebuilt 2026-10-15** (target rating 4, 5 waves); see §5.3. Awaiting playtest. |
| 13 | Same as 12 (Crawler, Occulum, SpinalOcculum, Wyrm, Hive, Maw, Portal) | 500 | **Rebuilt 2026-10-16** (target rating 5, 5 waves, fixed spawn order); see §5.4. Awaiting playtest. |
| 14 | Crawler, Occulum, SpinalOcculum, Wyrm, Hive, Maw, Portal, Hero | 600 | **Rebuilt 2026-10-16** (target rating 5, **6 waves**, escalating type mix); see §5.5. Awaiting playtest. |
| 15 | Same as 14 (duplicated from it) | 600 | **Built 2026-10-19** (target rating 5, 6 waves, **Ranged and Tank debut**); see §5.6. Awaiting playtest. |
| 16 | Same as 14 (duplicated from it) | 600 | **Built 2026-10-19** (target rating 5, 6 waves, heavier blend, 4 Tanks); see §5.7. Awaiting playtest. |

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

### 5.2 Level 11 (rebuilt 2026-10-15, awaiting playtest)

**Brief:** rating 4; 5 waves. Swarm and elite waves alternate: Green goes swarm, elite,
swarm, elite, swarm, and Purple the opposite. Severed fill out the swarms; no Reanimators
(keeps the screen readable). Allowed types: Severed, Unhallower, Erupter, Amalgam, Buffer,
Sundered. Starting blood 500 per dimension. Toolkit: Crawler, Occulum, SpinalOcculum,
Wyrm, Hive, Portal.

**Pre-placed Maws (free):** Purple lanes 1, 4, 7; Green lanes 2, 6. They sit mid-screen on
columns 11–12 (`pre_place_maw_demons()` in both level scripts). The Maw button stays hidden.

**Lane order:**
- Wave 1: Purple 3 and 5; Green 1, 2, 6, 7.
- Wave 2: Purple adds 1 and 7; Green adds none.
- Wave 3: both add 4.
- Wave 4 onwards: all 7.

**Gaps:** 70 / 95 / 105 / 110 s.

S = swarm, E = elite, "—" = lane closed, **M** = lane with a Maw.

**Green** (S · E · S · E · S)
| Lane | W1 (S) | W2 (E) | W3 (S) | W4 (E) | W5 (S) |
|---|---|---|---|---|---|
| 1 | 6 Severed, Sundered | Unhallower, Amalgam | 8 Severed, Amalgam | Unhallower, Amalgam, Sundered | 9 Severed, Amalgam |
| 2 M | 4 Severed | Erupter, Unhallower | 7 Severed, Buffer | Erupter, Unhallower, Buffer | 9 Severed, Buffer, Erupter |
| 3 | — | — | — | Unhallower, 2 Amalgam | 9 Severed, Amalgam, Sundered |
| 4 | — | — | 6 Severed, Sundered | 2 Amalgam, Sundered | 9 Severed, Buffer |
| 5 | — | — | — | Unhallower, 2 Amalgam | 9 Severed, Amalgam, Sundered |
| 6 M | 4 Severed | Erupter, Unhallower | 7 Severed, Buffer | Erupter, Unhallower, Buffer | 9 Severed, Buffer, Erupter |
| 7 | 6 Severed, Sundered | Unhallower, Amalgam | 8 Severed, Amalgam | Unhallower, Amalgam, Sundered | 9 Severed, Amalgam |
| Danger | 150 | 350 | 355 | 775 | 715 |
| Zombies | 22 | 8 | 41 | 21 | 74 |

**Purple** (E · S · E · S · E)
| Lane | W1 (E) | W2 (S) | W3 (E) | W4 (S) | W5 (E) |
|---|---|---|---|---|---|
| 1 M | — | 4 Severed, Sundered | Erupter, Unhallower, Amalgam | 7 Severed, Sundered | Erupter, Unhallower, Amalgam, Sundered |
| 2 | — | — | — | 8 Severed, Amalgam | 2 Unhallower, Buffer |
| 3 | Unhallower, Amalgam, Sundered | 7 Severed, Amalgam | Unhallower, Buffer, Sundered | 8 Severed, Buffer | Unhallower, 2 Amalgam |
| 4 M | — | — | Erupter, Unhallower | 7 Severed, Erupter | 2 Erupter, Unhallower, Amalgam |
| 5 | Unhallower, Amalgam, Sundered | 7 Severed, Amalgam | Unhallower, Buffer, Sundered | 8 Severed, Buffer | Unhallower, 2 Amalgam |
| 6 | — | — | — | 8 Severed, Amalgam | 2 Unhallower, Buffer |
| 7 M | — | 4 Severed, Sundered | Erupter, Unhallower, Amalgam | 7 Severed, Sundered | Erupter, Unhallower, Amalgam, Sundered |
| Danger | 200 | 210 | 600 | 515 | 975 |
| Zombies | 6 | 26 | 14 | 60 | 24 |

**Totals (both dimensions):** danger 350 · 560 · 955 · 1,290 · 1,690 = **4,845**; HP 6.3k ·
8.5k · 12.0k · 18.6k · 22.6k = 68k; zombies 28 · 34 · 55 · 81 · 98; peak pressure 704.
That's slightly above Level 8 (4,618 / 60k / 717) on raw numbers. About 60% of the danger
is in elite waves, which the Maws eat into, and there's +100 blood and the Hive. Expected
to play as a 4; the least certain number in these notes, since no Maw level has been
playtested.

**Design intent:**
- **The Maws counter elites, and the swarms threaten the Maws.** A Maw eats the first 3
  zombies in reach, then digests for 15 s, and its 73 px reach covers about 2 lanes either
  side. Between them, the 5 Maws cover every lane at mid-screen. Zombies left over in a Maw's
  own lane eat it (800 HP) while it digests, so keeping the Maws alive through the swarms
  (e.g. a SpinalOcculum in front) is the level's core skill. A Wyrm next to a Maw cuts its
  digestion to 5 s.
- Elite waves outgrow the Maws: 6 heavies vs 1 Maw (Purple W1, the Maw showcase); then 8 vs
  6 tentacles, 14 vs 9, 21 vs 6, 24 vs 9.
- Erupters are the elite waves' tentacle bait. They're the fastest zombie, so they always
  arrive first, and an eaten Erupter doesn't explode. Each one ties up a tentacle for 15 s.
- Maw lanes get only 4 Severed in the first wave each Maw faces, so one SpinalOcculum in
  front saves it. Later swarms (7–9 per lane) kill unprotected Maws.
- **Levers if it plays too hard, in order:**
  1. Cut 1 Severed per lane in Green W5 / Purple W4.
  2. Drop the elite-wave Buffers.
  3. Add 10 s to gaps 3 and 4.
- **If the elites feel free:** add 1 Erupter per Maw lane, or +1 Unhallower in non-Maw
  lanes.
- Preset `Level 11 v1` holds this version.

### 5.3 Level 12 (rebuilt 2026-10-15, awaiting playtest)

**Brief:** rating 4; 5 waves. Like Level 10, but with even fewer, stronger zombies, because
this is where the player gets the Maw and should be able to use it in a near-ideal
setting. Flesheater debuts in waves 4–5. Allowed types: Unhallower, Reanimator, Erupter,
Amalgam, Buffer, Sundered, Flesheater. Starting blood 500 per dimension.

**Lane order** (the brief's "Purple adds lane 7" in W3 was confirmed to mean Green):
- Wave 1: Green 3, 4, 5; Purple 1, 2, 6, 7.
- Wave 2: Green adds 2 and 6; Purple adds 4.
- Wave 3: Green adds 7; Purple adds none.
- Wave 4 onwards: all 7.

**Gaps:** 75 / 95 / 105 / 110 s.

**Green**
| Lane | W1 | W2 | W3 | W4 | W5 |
|---|---|---|---|---|---|
| 1 | — | — | — | Amalgam, Sundered | 2 Unhallower |
| 2 | — | Amalgam | Unhallower | Unhallower, Buffer | Flesheater |
| 3 | Unhallower | Unhallower, Sundered | Unhallower, Buffer | Erupter, Unhallower | Erupter, Unhallower, Buffer |
| 4 | Unhallower | Erupter, Unhallower | Reanimator | Flesheater | Reanimator, Unhallower |
| 5 | Unhallower | Unhallower | Erupter, Unhallower | Reanimator | Erupter, Unhallower |
| 6 | — | Amalgam | Unhallower | Unhallower, Buffer | Flesheater |
| 7 | — | — | Unhallower | Unhallower | Unhallower, Buffer |
| Danger | 150 | 275 | 450 | 650 | 900 |
| Zombies | 3 | 7 | 8 | 11 | 13 |

**Purple**
| Lane | W1 | W2 | W3 | W4 | W5 |
|---|---|---|---|---|---|
| 1 | Amalgam | Unhallower | Unhallower, Buffer | Unhallower, Buffer | Flesheater, Sundered |
| 2 | Unhallower | Amalgam, Sundered | Reanimator | Erupter, Unhallower | Unhallower, Buffer |
| 3 | — | — | — | Unhallower | Erupter, Unhallower |
| 4 | — | Erupter, Unhallower | Erupter, Unhallower | Flesheater | Reanimator, Unhallower |
| 5 | — | — | — | Unhallower | Erupter, Unhallower |
| 6 | Unhallower | Amalgam | Unhallower, Amalgam | Reanimator | Unhallower, Buffer |
| 7 | Amalgam | Unhallower | Unhallower, Sundered | Unhallower, Buffer | Flesheater, Sundered |
| Danger | 150 | 275 | 450 | 650 | 900 |
| Zombies | 4 | 7 | 9 | 10 | 14 |

**Totals (both dimensions):** danger 300 · 550 · 900 · 1,300 · 1,800 = **4,850**; zombies
7 · 14 · 17 · 21 · 27 = 86; about 35k HP; peak pressure 709. Level 10 had 110 zombies at
about 37 danger each; Level 12 has 86 at about 56. Expected to play as 3.5 to 4, depending on
how quickly players afford Maws (275 each against 500 starting blood).

**Design intent:**
- Maw intro in wave 1: Green sends 3 Unhallowers down the middle lanes, so one Maw on lane 4
  eats all three. Purple splits lanes 1–2 and 6–7, so where the Maw goes matters.
- Unhallowers are the bulk (40 of 86). They're armored, so Crawlers barely hurt them, which
  makes the Maw (or a Wyrm) the clear answer.
- One Reanimator per dimension from wave 3. A Maw kills it in one bite; left alone, its
  Wretches tie up the Maw's tentacles.
- Flesheater: one per dimension in wave 4 (centre lane 4, easy for a Maw to reach), two
  per dimension in wave 5 (Green 2 and 6; Purple 1 and 7, harder to reach).
- Erupters (10 in total) arrive first and tie up tentacles. Buffers travel with Unhallowers.
- The first Flesheater shows the new-zombie button; clicking it opens the Flesheater
  description and demo (`show_zombie_tutorial` in both level scripts).
- **Levers if it plays too hard:** drop the wave 5 Buffers, then 1 Unhallower per dimension
  in wave 5. **If too easy:** add Erupters to tie up the Maws.
- Preset `Level 12 v1` holds this version.

### 5.4 Level 13 (rebuilt 2026-10-16, awaiting playtest)

**Brief:** rating 5; 5 waves; more balanced overall. Both dimensions mix strong and weak
zombies across all nine types (Reborn, Severed, Unhallower, Reanimator, Erupter, Amalgam,
Buffer, Sundered, Flesheater). The dimensions differ mainly through **spawn order**: each
gets its own mix, and every spawner has `is_random = false`. Starting blood 500 per
dimension. Toolkit is the same as Level 12.

**Lane order** (Green mirrors Purple):
- Wave 1: Purple 1, 2, 3; Green 5, 6, 7.
- Wave 2: Purple adds 7; Green adds 1.
- Wave 3: Purple adds 5; Green adds 3.
- Wave 4: both add 4.
- Wave 5: all 7.

**Gaps:** 70 / 95 / 105 / 110 s.

**How fixed order plays out:** a lane spawns its entries top to bottom, about 1.5 s apart,
and then speed reshapes them on the way down.
- **Purple is tank-first.** The strong zombie leads, and Reborn (same 8 px/s as an
  Unhallower) cluster right behind it like a shield wall. The Maw or Wyrm meets the tank
  first, and the fodder floods in while the Maw digests.
- **Green is fodder-first.** Fodder spawns first. Fast strong units (Amalgam and
  Flesheater, 16 px/s) catch the pack mid-lane; a slow Unhallower trails behind it. The
  fodder soaks up Maw tentacles and Wyrm shots before the strong zombie arrives.
- Erupters (48 px/s) arrive first whatever their position.
- Each type appears at most once per lane-wave, so the Wave Table Editor grid can still
  edit it.

Cells are in spawn order (→).

**Purple** (tank-first)
| Lane | W1 | W2 | W3 | W4 | W5 |
|---|---|---|---|---|---|
| 1 | Unhallower → 4 Reborn | Unhallower → Buffer → 5 Reborn | Unhallower → Amalgam → 5 Reborn | Flesheater → 4 Severed | 2 Unhallower → Buffer → 5 Reborn |
| 2 | Amalgam → 4 Severed → Sundered | Reanimator → 4 Severed | Flesheater → 5 Severed | 2 Unhallower → Buffer → 4 Reborn | Flesheater → Amalgam → 5 Severed |
| 3 | Unhallower → 4 Reborn | Amalgam → 4 Severed | Unhallower → Buffer → 5 Severed | Reanimator → Amalgam → 4 Severed | Reanimator → Unhallower → 4 Reborn |
| 4 | — | — | — | Amalgam → 4 Reborn → Sundered | Flesheater → Buffer → 5 Severed |
| 5 | — | — | Amalgam → 4 Reborn → Erupter | Unhallower → Amalgam → 4 Severed | Unhallower → 2 Amalgam → 5 Severed → Erupter |
| 6 | — | — | — | — | Unhallower → Amalgam → 4 Reborn → Sundered |
| 7 | — | Unhallower → 4 Reborn | Reanimator → 5 Reborn | Flesheater → Buffer → 4 Reborn | Reanimator → Amalgam → 5 Severed |
| Danger | 186 | 333 | 578 | 834 | 1,176 |
| Zombies | 16 | 22 | 32 | 36 | 51 |

**Green** (fodder-first)
| Lane | W1 | W2 | W3 | W4 | W5 |
|---|---|---|---|---|---|
| 1 | — | 4 Reborn → Amalgam | 5 Severed → Sundered → Amalgam | 4 Severed → Buffer → Amalgam | 5 Severed → Erupter → Flesheater |
| 2 | — | — | — | — | 4 Reborn → Sundered → Amalgam → Unhallower |
| 3 | — | — | 4 Reborn → Unhallower → Amalgam | 4 Reborn → Erupter → Unhallower | 5 Severed → Buffer → Sundered → 2 Amalgam |
| 4 | — | — | — | 4 Severed → Sundered → Amalgam | 4 Reborn → Reanimator → Unhallower |
| 5 | 4 Severed → Amalgam | 4 Severed → Buffer → Amalgam | 5 Severed → Buffer → Flesheater | 4 Severed → Amalgam → Flesheater | 5 Severed → Buffer → Flesheater |
| 6 | 4 Reborn → Sundered → Unhallower | 5 Reborn → Reanimator | 5 Reborn → Erupter → Amalgam | 4 Reborn → Reanimator → Amalgam | 5 Reborn → Erupter → 2 Amalgam |
| 7 | 4 Severed → Sundered → Amalgam | 4 Severed → Erupter → Amalgam | 5 Severed → Reanimator | 4 Severed → Buffer → Flesheater | 5 Severed → Sundered → Flesheater |
| Danger | 198 | 333 | 593 | 821 | 1,176 |
| Zombies | 17 | 23 | 33 | 36 | 51 |

**How the dimensions differ:**
- **Purple** leans slow and grinding: 14 Unhallowers and 5 Reanimators, with Reborn.
- **Green** leans fast: 17 Amalgams, 7 Sundered and 5 Erupters, with Severed.
- Both use all nine types, with 5–6 Flesheaters and 6 Buffers. Danger is 3,107 vs 3,121.

**Totals (both dimensions):** danger 384 · 666 · 1,171 · 1,655 · 2,352 = **6,228**; HP
6.4k · 7.6k · 11.6k · 14.6k · 21.5k = 61.6k; zombies 33 · 45 · 65 · 72 · 102 = 317; peak
pressure 903. That's about 35% more danger than Level 8 (4,618, rated 5 without Hive or
Maw) at similar HP: the player now has Hive, Maw and 500 blood. Mixed waves also blunt
any one-counter build: fodder clogs the Maws, and tanks shrug off the Wyrm's spread
damage.

- **Levers if it plays too hard:** drop the 4 wave 5 Buffers; then 1 fodder per lane in
  waves 4–5; then +10 s on gaps 3–4.
- **If too easy:** swap one wave 5 Amalgam per dimension for a Flesheater.
- Preset `Level 13 v1` holds this version.

### 5.5 Level 14 (rebuilt 2026-10-16, awaiting playtest)

**Brief:** rating 5; **6 waves**; complexity escalates. Wave 1 is only Reborn and Severed.
Each later wave adds types and keeps every earlier one. All 9 types appear by wave 5, and
again in wave 6. Reborn and Severed stay a swarm threat without crowding the screen.
Starting blood 600 per dimension. Toolkit (left as the script has it): Crawler, Occulum,
SpinalOcculum, Wyrm, Hive, Maw, Portal, Hero. Spawning is random within a lane. The scenes
had no WaveTableHost; one was added to both.

**Type unlocks** (each dimension in its own order; every wave keeps everything earlier):
| Wave | Purple adds (tanks first) | Green adds (specialists first) | Types per dimension |
|---|---|---|---|
| 1 | Reborn, Severed | Reborn, Severed | 2 |
| 2 | Unhallower, Amalgam | Sundered, Buffer | 4 |
| 3 | Reanimator, Flesheater | Erupter, Amalgam | 6 |
| 4 | Sundered, Buffer | Unhallower, Reanimator | 8 |
| 5 | Erupter | Flesheater | 9 |
| 6 | — | — | 9 |

**Lanes:**
- Wave 1: lane 4.
- Wave 2: 3–5.
- Wave 3: 2–6.
- Wave 4: Purple 1–6, Green 2–7.
- Waves 5–6: all.

**Gaps:** 55 / 80 / 95 / 105 / 110 s. `level14.gd` passes all 5 gaps, giving 6 waves.

**Purple** (tanks first)
| Lane | W1 | W2 | W3 | W4 | W5 | W6 |
|---|---|---|---|---|---|---|
| 1 | — | — | — | 4 Reborn, Unhallower, Sundered | 4 Severed, Unhallower, Buffer | 4 Reborn, 2 Unhallower, Buffer, Amalgam |
| 2 | — | — | 4 Reborn, Unhallower, Amalgam | 4 Severed, Amalgam, Buffer | 4 Reborn, Amalgam, Erupter | 4 Severed, Flesheater, Amalgam |
| 3 | — | 4 Reborn, 2 Severed, Unhallower | 4 Severed, Reanimator | 3 Reborn, Reanimator, Unhallower | 4 Severed, Reanimator, Sundered | 4 Reborn, Reanimator, Unhallower |
| 4 | 8 Reborn, 6 Severed | 3 Severed, 2 Amalgam | 3 Severed, Flesheater | 4 Severed, Flesheater | 3 Reborn, Flesheater, Amalgam | 4 Severed, Flesheater, Erupter |
| 5 | — | 4 Reborn, 2 Severed, Unhallower | 4 Reborn, 2 Severed, Unhallower | 4 Reborn, Amalgam, Sundered | 4 Severed, Unhallower, Amalgam | 4 Reborn, Reanimator, Amalgam |
| 6 | — | — | 3 Severed, Amalgam | 4 Severed, Unhallower, Buffer | 4 Reborn, Reanimator | 4 Severed, Unhallower, Buffer, Sundered |
| 7 | — | — | — | — | 4 Severed, Unhallower, Sundered | 4 Reborn, Unhallower, Erupter, Sundered |
| Danger | 46 | 201 | 476 | 682 | 827 | 1,167 |
| Zombies | 14 | 19 | 26 | 34 | 40 | 46 |

**Green** (specialists first)
| Lane | W1 | W2 | W3 | W4 | W5 | W6 |
|---|---|---|---|---|---|---|
| 1 | — | — | — | — | 4 Severed, Sundered, Erupter | 4 Reborn, Flesheater, Sundered |
| 2 | — | — | 4 Severed, Sundered, Erupter | 4 Reborn, Unhallower, Sundered, Amalgam | 4 Reborn, Unhallower, Buffer | 4 Severed, Unhallower, Erupter, Sundered |
| 3 | — | 4 Severed, 2 Sundered | 4 Reborn, Amalgam, Buffer | 4 Severed, Amalgam, Erupter | 4 Severed, Amalgam, Sundered | 4 Reborn, Reanimator, Buffer, Amalgam |
| 4 | 6 Reborn, 7 Severed | 5 Reborn, 2 Severed, Buffer | 4 Severed, 2 Sundered, Amalgam | 4 Reborn, Reanimator, Buffer | 4 Reborn, Flesheater, Buffer | 4 Severed, Flesheater, Amalgam |
| 5 | — | 4 Severed, 2 Sundered | 4 Reborn, Amalgam, Buffer | 4 Severed, Unhallower, Sundered | 4 Severed, Reanimator, Sundered | 4 Reborn, Unhallower, Erupter, Amalgam |
| 6 | — | — | 4 Severed, Sundered, Erupter | 4 Reborn, Amalgam, Erupter | 4 Reborn, Amalgam, Erupter | 4 Severed, Reanimator, Sundered |
| 7 | — | — | — | 4 Severed, Sundered, Erupter, Amalgam | 4 Severed, Unhallower, Amalgam | 4 Reborn, Unhallower, Buffer, Sundered |
| Danger | 47 | 210 | 451 | 659 | 804 | 1,117 |
| Zombies | 13 | 20 | 31 | 38 | 42 | 46 |

**Totals (both dimensions):** danger 93 · 411 · 927 · 1,341 · 1,631 · 2,284 = **6,687**; HP
2.9k · 6.5k · 10.2k · 13.6k · 15.7k · 18.2k = 67k; zombies 27 · 39 · 57 · 72 · 82 · 92 =
369; peak pressure 890. That's on par with Level 13 (also a 5: 6,228 / 61.6k / 903), with
+100 blood and one extra wave.

**Design intent:**
- Wave 1 is one swarm lane of 13–14 Reborn and Severed. After that it's 2–4 fodder per
  lane alongside the specials: about 60% of the bodies, but little of the danger. The final
  wave is 92 zombies (Level 13: 102).
- Purple (3,399 danger) leans on tanks: 15 Unhallowers, 6 Reanimators, 5 Flesheaters.
  Green (3,288) leans on tricks: 18 Sundered, 8 Erupters, 9 Buffers. Mid-level, Purple hits
  harder in HP and Green is harder to read.
- **Levers if it plays too hard:** drop 1 fodder per lane in waves 5–6; then the wave 6
  Buffers; then +10 s on gaps 4–5. **If too easy:** add a second Flesheater to each
  dimension's wave 6.
- Preset `Level 14 v1` holds this version.

### 5.6 Level 15 (built 2026-10-19, awaiting playtest)

**Brief:** rating 5; 6 waves; waves mix swarm types with higher-HP units. Within each wave
the two dimensions share **no** zombie types, except Ranged, which debuts here in both
dimensions from wave 5 (the second-to-last wave). Allowed types: Reborn, Severed,
Unhallower, Reanimator, Erupter, Amalgam, Buffer, Sundered, Flesheater, Tank, Ranged.
Starting blood 600. The level was duplicated from Level 14 by the designer (same toolkit,
Hero included). Spawning is random within a lane.

**Lanes:**
- Wave 1: 3–5.
- Wave 2: Purple adds 2, Green adds 6.
- Wave 3: Purple adds 1, Green adds 7.
- Waves 4–6: all.

**Gaps:** 65 / 85 / 95 / 105 / 110 s.

**How the rules are met (checked by script):**
- No type is shared between the dimensions in any wave except Ranged.
- Every lineup has a swarm type plus at least one heavy. Reborn and Severed swap
  dimensions every wave.
- Ranged appears only in waves 5–6, in both dimensions.
- Tanks: one in Purple wave 4 and one in Green wave 6, both in lane 4. A shared type isn't
  allowed, so they can't appear in both dimensions in the same wave.

**Purple**
| Lane | W1 | W2 | W3 | W4 | W5 | W6 |
|---|---|---|---|---|---|---|
| 1 | — | — | 6 Reborn, Unhallower | 4 Severed, Amalgam | 4 Reborn, Unhallower, Sundered | 5 Severed, Amalgam, Erupter |
| 2 | — | 5 Severed, Amalgam | 6 Reborn, Reanimator | 4 Severed, Amalgam, Buffer | 4 Reborn, Unhallower, Ranged | 5 Severed, Ranged, Buffer |
| 3 | 5 Reborn, Unhallower | 5 Severed, Sundered | 5 Reborn, Unhallower, Erupter | 4 Severed, Amalgam | 4 Reborn, Flesheater | 5 Severed, Amalgam, Reanimator |
| 4 | 8 Reborn | 5 Severed, Amalgam, Sundered | 6 Reborn, Unhallower | 4 Severed, **Tank** | 4 Reborn, Unhallower, Sundered | 5 Severed, Amalgam, Ranged |
| 5 | 5 Reborn, Unhallower | 5 Severed, Amalgam | 5 Reborn, Reanimator | 4 Severed, Amalgam | 4 Reborn, Flesheater | 5 Severed, Reanimator, Buffer |
| 6 | — | — | — | 4 Severed, Amalgam, Buffer | 4 Reborn, Ranged | 5 Severed, Ranged, Erupter |
| 7 | — | — | — | 4 Severed, Amalgam | 4 Reborn, Unhallower, Sundered | 5 Severed, Amalgam, Reanimator |
| Danger | 136 | 225 | 456 | 790 | 831 | 1,075 |
| Zombies | 20 | 25 | 34 | 37 | 39 | 49 |

**Green**
| Lane | W1 | W2 | W3 | W4 | W5 | W6 |
|---|---|---|---|---|---|---|
| 1 | — | — | — | 4 Reborn, Unhallower | 4 Severed, Amalgam, Erupter | 5 Reborn, Unhallower, Sundered |
| 2 | — | — | — | 4 Reborn, Unhallower, Erupter | 4 Severed, Amalgam, Ranged | 5 Reborn, Flesheater, Ranged |
| 3 | 4 Severed, Amalgam | 5 Reborn, Unhallower | 5 Severed, Amalgam, Sundered | 4 Reborn, Flesheater | 4 Severed, Reanimator | 5 Reborn, Unhallower |
| 4 | 5 Severed, Amalgam | 6 Reborn, Buffer | 5 Severed, Flesheater | 4 Reborn, Unhallower, Sundered | 4 Severed, Amalgam, Buffer | 4 Reborn, **Tank** |
| 5 | 4 Severed, Amalgam | 5 Reborn, Unhallower | 5 Severed, Amalgam, Sundered | 4 Reborn, Flesheater | 4 Severed, Reanimator | 5 Reborn, Unhallower |
| 6 | — | 5 Reborn, Unhallower | 5 Severed, Amalgam | 4 Reborn, Unhallower, Erupter | 4 Severed, Ranged | 5 Reborn, Flesheater, Ranged |
| 7 | — | — | 5 Severed, Amalgam, Sundered | 4 Reborn, Unhallower, Sundered | 4 Severed, Amalgam, Erupter | 5 Reborn, Unhallower, Sundered |
| Danger | 140 | 242 | 450 | 756 | 790 | 1,218 |
| Zombies | 16 | 25 | 33 | 39 | 39 | 45 |

**Totals (both dimensions, Tank 400 / Ranged 100):** danger 276 · 467 · 906 · 1,546 ·
1,621 · 2,293 = **7,109**; about 72k HP; zombies 36 · 50 · 67 · 76 · 78 · 94 = 401, plus the
Minions each Tank launches (unscored); peak pressure 884. That's on par with Level 14
(6,687 / 67k / 890, also a 5), slightly heavier, with two Tanks and the Ranged debut.

**Debut wiring:**
- The first Ranged and the first Tank each show the new-zombie button in either dimension
  (`"Ranged"` was added to `Global.zombie_notif_icons`).
- Clicking it opens a **text-only** pop-up (`set_basic_tutorial_text`) with the draft
  descriptions in `ZombieDescriptions/rangedZombieDescription.txt` and
  `tankZombieDescription.txt`. Swap in demo scenes once they exist.
- The descriptions aren't in the translation CSV yet; `Loc.text` falls back to the file.

**Known issue in play:** the Tanks launch Minions, and clicking a Minion still errors
(`Global.minion_icon` doesn't exist; §2).

**Levers if it plays too hard:** drop 1 fodder per lane in waves 5–6; then move Green's
wave 6 Tank to a plain Unhallower; then +10 s on gaps 4–5.

Preset `Level 15 v1` holds this version.

### 5.7 Level 16 (built 2026-10-19, awaiting playtest)

**Brief:** rating 5; 6 waves; low-health swarmers blend with higher-health units, **trending
toward the higher-health units**. All 11 types allowed (Tank and Ranged debuted in Level 15).
Starting blood 600. Duplicated from Level 14 by the designer. Spawning is random within a
lane.

**Lanes:**
- Wave 1: lanes 1 and 7.
- Wave 2: Purple adds 2, Green adds 6.
- Wave 3: Purple adds 3, Green adds 5.
- Waves 4–6: all.

**Gaps:** 60 / 85 / 95 / 105 / 115 s.

**The heavy trend (checked by script):**
- Every lane in every wave has a swarm type and at least one heavy.
- Fodder per lane drops from 5–6 (waves 1–2) to 4 (wave 3) to 3 (waves 4–6), while heavies
  per lane rise from 1 to 1–2.
- Heavies' share of the HP climbs from about 34–66% in wave 1 to about 71% in wave 6.
- **Tanks:** Purple waves 4 and 6, Green waves 5 and 6, all in lane 4 (4 in total).
- **Ranged:** from wave 3.

**Purple**
| Lane | W1 | W2 | W3 | W4 | W5 | W6 |
|---|---|---|---|---|---|---|
| 1 | 6 Reborn, Unhallower | 5 Severed, Amalgam | 4 Reborn, Unhallower, Sundered | 3 Severed, Unhallower | 3 Reborn, Unhallower | 3 Severed, Unhallower, Amalgam |
| 2 | — | 5 Reborn, Unhallower | 4 Severed, Flesheater | 3 Reborn, Unhallower | 3 Severed, Flesheater | 3 Reborn, Flesheater |
| 3 | — | — | 4 Reborn, Unhallower, Ranged | 3 Severed, Amalgam | 3 Reborn, Reanimator | 3 Severed, Amalgam, Reanimator |
| 4 | — | — | — | 3 Reborn, **Tank** | 3 Severed, Amalgam, Ranged | 3 Reborn, **Tank** |
| 5 | — | — | — | 3 Severed, Ranged | 3 Reborn, Unhallower | 3 Severed, Amalgam, Ranged |
| 6 | — | — | — | 3 Reborn, Unhallower, Sundered | 3 Severed, Flesheater | 3 Reborn, Flesheater |
| 7 | 6 Reborn, Unhallower | 5 Severed, Reanimator | 4 Severed, Amalgam, Erupter | 3 Severed, Amalgam | 3 Reborn, Amalgam, Ranged | 3 Severed, Amalgam, Ranged |
| Danger | 124 | 235 | 506 | 803 | 819 | 1,228 |
| Zombies | 14 | 18 | 23 | 29 | 30 | 32 |

**Green**
| Lane | W1 | W2 | W3 | W4 | W5 | W6 |
|---|---|---|---|---|---|---|
| 1 | 5 Severed, Amalgam | 5 Reborn, Unhallower | 4 Severed, Amalgam, Erupter | 3 Reborn, Reanimator | 3 Severed, Ranged | 3 Reborn, Unhallower, Ranged |
| 2 | — | — | — | 3 Severed, Amalgam, Sundered | 3 Reborn, Unhallower | 3 Severed, Amalgam, Reanimator |
| 3 | — | — | — | 3 Reborn, Unhallower, Erupter | 3 Severed, Amalgam | 3 Reborn, Flesheater |
| 4 | — | — | — | 3 Severed, Flesheater | 3 Reborn, **Tank** | 3 Severed, **Tank** |
| 5 | — | — | 4 Reborn, Amalgam, Ranged | 3 Reborn, Amalgam, Ranged | 3 Severed, Flesheater | 3 Reborn, Unhallower, Erupter |
| 6 | — | 5 Severed, Amalgam | 4 Severed, Flesheater | 3 Severed, Amalgam, Buffer | 3 Reborn, Amalgam | 3 Severed, Reanimator |
| 7 | 5 Severed, Amalgam | 5 Reborn, Reanimator | 4 Reborn, Unhallower, Sundered | 3 Reborn, Unhallower, Amalgam | 3 Severed, Ranged | 3 Reborn, Amalgam, Ranged |
| Danger | 100 | 220 | 481 | 744 | 928 | 1,219 |
| Zombies | 12 | 18 | 23 | 33 | 28 | 32 |

**Totals (both dimensions):** danger 224 · 455 · 987 · 1,547 · 1,747 · 2,447 = **7,407**;
HP 62.9k; zombies 26 · 36 · 46 · 62 · 58 · 64 = 292, plus Minions from the 4 Tanks; peak
pressure 911. Compared with Level 15 (7,109 / 72k / 401 / 884): slightly more danger and
far fewer bodies, with more of the HP in heavies. Purple leans on Unhallowers (11), Green
on Amalgams (13) and Erupters; 3,715 vs 3,692 danger.

**Levers if it plays too hard:** remove one dimension's wave 6 Tank (−400); then drop 1
fodder per lane in waves 5–6; then +10 s on gaps 3–4. **If too easy:** add an Unhallower to
wave 5 lanes 2 and 6 in both dimensions.

**Known in play:** the Minion-click error (§2) applies; 4 Tanks launch Minions here.

Preset `Level 16 v1` holds this version.

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

Reborn 2, Unhallower 50, Sundered 25, Minion 5 and Rohan 1000 look right as they are. Tank
(250 → 400) and Ranged (75 → 100) were **applied** on 2026-10-19; see the change log.

## 7. Change log
- 2026-10-12 — Flesheater: speed 32 → 16 (Medium); health regen turned on at 7 HP every 2 s
  (3.5 HP/s).
- 2026-10-12 — Level 10: pre-placed Hives confirmed as intended; lane 1's fixed spawn order
  confirmed as unintended.
- 2026-10-12 — Level 10 rebuilt: 5 waves, gaps 75/95/105/110, 500 starting blood, new lane
  order, lane 1 randomized, Erupter notification (§5.1).
- 2026-10-12 — Wave presets added to the Wave Table Editor (§1); Level 10 seeded with
  `Level 10 v1` and `L10 original`.
- 2026-10-15 — Level 11 rebuilt: 5 alternating swarm/elite waves, gaps 70/95/105/110,
  5 pre-placed Maws, Hive added to the toolkit, waves moved from code to the scenes (§5.2).
- 2026-10-15 — Maw row in §3 corrected from the code: 3 tentacles, 73 px reach, an eaten
  Erupter doesn't explode.
- 2026-10-15 — Level 11/12 scripts: own level paths, dropped the duplicate `level_ended`
  and ToolTipHid connects and the Coral-less sway call (mirrors the Level 10 cleanup).
- 2026-10-15 — Level 12 rebuilt: 5 waves, gaps 75/95/105/110, Flesheater debut with its
  tutorial, Hive and Maw added to the toolkit, waves moved from code to the scenes (§5.3).
- 2026-10-15 — Level 10: clicking the Erupter notification now opens its description and
  demo (it did nothing before).
- 2026-10-16 — Level 13 rebuilt: 5 waves with fixed spawn order (Purple tank-first, Green
  fodder-first), gaps 70/95/105/110, Hive and Maw added to the toolkit, waves moved from
  code to the scenes, and the same script cleanup as Levels 10–12 (§5.4).
- 2026-10-16 — Level 14 rebuilt: 6 waves with escalating type unlocks (each dimension in
  its own order), gaps 55/80/95/105/110, 600 starting blood, a WaveTableHost added to both
  scenes, waves moved from code to the scenes, and the same script cleanup (§5.5).
- 2026-10-19 — `DANGER_SCORES`: Tank 250 → 400 and Ranged 75 → 100 (Ranged out-damages every
  regular zombie from outside Maw reach; Tank is Maw-proof and launches unscored Minions).
  Danger totals quoted for Levels 10–14 are unchanged, since none of them use Tank or
  Ranged.
- 2026-10-19 — Level 15 built (§5.6): 6 waves, separate lineups per dimension, Ranged and
  Tank debut with unlock buttons and text-only pop-ups (draft descriptions), gaps
  65/85/95/105/110, root nodes renamed from the copied `Level_14`, level paths fixed.
- 2026-10-19 — Levels 12 and 15: closing a zombie pop-up no longer advances into the leftover
  `GAME_READY` tutorial step. In Level 12 that step hit a null `green_dimension` when the
  Flesheater pop-up was closed on a first (non-restart) play.
- 2026-10-19 — Level 16 built (§5.7): 6 waves trending toward heavies, 4 Tanks, gaps
  60/85/95/105/115, roots renamed from the copied `Level_14`, level paths fixed, the same
  pop-up handler fix as Levels 12/15, and the copied `L14 v1` preset replaced by `Level 16 v1`.
- 2026-10-19 — Act 2 Boss implemented (§2) and registered as `Act2Boss` (danger 1000). Its
  health, speed and damage values are placeholders to tune.
- 2026-10-19 — Act 3 Boss Argus and his Heralds implemented (§2), registered as `Argus`
  (danger 1000). Health, damage and timers are placeholders.
