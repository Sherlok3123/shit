# BLUESENSE_MODULE_MAP.md
========================================
Phase 12 — BLUESENSE Module Map & Data Flow

Scope: Module and callback relationship analysis for BLUESENSE.lua.txt.
Evidence levels: CONFIRMED / STRONGLY SUPPORTED / INFERRED / UNKNOWN.

========================================
1. MODULE HIERARCHY (slot_0_XX naming convention)
========================================

The Neverlose Lua scripts use an obfuscated naming convention where all
variables are prefixed with `slot_0_XX_Y`. The `XX` appears to be a slot
number and `Y` appears to be a sub-index within that slot.

| Slot | Likely Purpose | Evidence |
|------|---------------|----------|
| slot_0_0 | Module identifier (`"bluesense"`) | CONFIRMED — line 3 |
| slot_0_1 | `neverlose` library root | CONFIRMED — `require("neverlose/pui")`, etc. |
| slot_0_2 | `neverlose/base64` | CONFIRMED — line 8 |
| slot_0_3 | `neverlose/clipboard` | CONFIRMED — line 9 |
| slot_0_4 | `neverlose/inspect` | CONFIRMED — line 10 |
| slot_0_5 | `neverlose/smoothy` | CONFIRMED — line 11 |
| slot_0_6 | `neverlose/easing` | CONFIRMED — line 12 |
| slot_0_7 / slot_0_8 | `neverlose/get_defensive` (pcall result) | CONFIRMED — line 13 |
| slot_0_9 | `get_defensive()` wrapper function | CONFIRMED — lines 15-29 |
| slot_0_10 | `get_players()` wrapper function | CONFIRMED — lines 31-41 |
| slot_0_11 | `slot_0_11_0` (state table) / `slot_0_11_1` (nil) | CONFIRMED — lines 45-46 |
| slot_0_12 | States array (standing, running, etc.) | CONFIRMED — lines 112-124 |
| slot_0_13 | `message()` and `error()` helper functions | CONFIRMED — lines 126-132 |
| slot_0_14 | `renderer.screen_size()` | CONFIRMED — line 134 |
| slot_0_15 - slot_0_25 | Font loading (Verdana various sizes) | CONFIRMED — lines 139-151 |
| slot_0_26 | nil | CONFIRMED — line 146 |
| slot_0_27 | `{}` empty table | CONFIRMED — line 147 |
| slot_0_28 | nil | CONFIRMED — line 148 |
| slot_0_29 | `render.load_font("Verdana", 24, "ab")` | CONFIRMED — line 148 |
| slot_0_30 | `render.load_font("Verdana", 10, "ab")` | CONFIRMED — line 149 |
| slot_0_31 | `render.load_font("Verdana", 14, "ab")` | CONFIRMED — line 150 |
| slot_0_32 | `render.load_font("Verdana", 13, "ab")` | CONFIRMED — line 151 |
| slot_0_33 | `render.load_font("Verdana", 12, "ab")` | CONFIRMED — line 151 |
| slot_0_34 | nil | CONFIRMED — line 154 |
| slot_0_35 | `{}` empty table | CONFIRMED — line 155 |
| slot_0_36 | `slot_0_36_0()` — registration function | CONFIRMED — lines 156-158 |

========================================
2. UI SECTIONS (ui.find / ui.create)
========================================

| Section | UI Path | Variable | Line |
|---------|---------|----------|------|
| MISC (main container) | `slot_0_61_2.misc` | `slot_0_61_2` | Line 3533 |
| EXPLOITS | `slot_0_83_6` (child of misc) | `slot_0_83_6` | Line 3533 |
| EXPLOITS — Lag Comp Delay | `slot_0_94_18.lagcomp_delay` | `slot_0_94_18.lagcomp_delay` | Line 3553 |
| EXPLOITS — FakeLag Editor | `slot_0_94_18.fake_lag_editor` | `slot_0_94_18.fake_lag_editor` | Line 3555 |
| EXPLOITS — Safe Point Defensive Users | `slot_0_95_19.defensive_safety` | `slot_0_95_19.defensive_safety` | Line 3734 |
| EXPLOITS — Lethal Body Aim | `slot_0_95_19.lethal_body` | `slot_0_95_19.lethal_body` | Line 3738 |
| EXPLOITS — Force Shoot | `slot_0_95_19.force_shoot` | `slot_0_95_19.force_shoot` | Line 3743 |
| MISC — Anim Breaker | `slot_0_96_20.anim_breaker` | `slot_0_96_20.anim_breaker` | Line 3803 |
| MISC — Clantag | `slot_0_99_23.enabled` | `slot_0_99_23.enabled` | Line 3826 |
| MISC — Kill Say | `slot_0_102_26.enabled` | `slot_0_102_26.enabled` | Line 3841 |
| ANTIAIM — Angles | `slot_0_11_0.rage.angles.*` | Multiple | Lines 74-92 |
| ANTIAIM — Fake Lag | `slot_0_11_0.antiaim.fake_lag.*` | `slot_0_11_0.antiaim.fake_lag.*` | Lines 93-104 |
| ANTIAIM — Misc | `slot_0_11_0.antiaim.misc.*` | `slot_0_11_0.antiaim.misc.*` | Lines 100-104 |
| ANTI-AIM BUILDER | `slot_0_76_7` (state-based config) | `slot_0_76_7` | Line 2172 |
| ANTI-AIM — State Selector | `slot_0_78_8` (list) | `slot_0_78_8` | Line 2187 |
| ANTI-AIM — Active On | `slot_0_76_7.active_on` | `slot_0_76_7.active_on` | Line 2192 |
| SAFE HEAD | `slot_0_72_6:switch(...)` | `slot_0_72_6.switch(...)` | Line 1231 |

========================================
3. CALLBACK REGISTRATION MAP
========================================

| Callback | Line | Trigger | Target | Confidence |
|----------|------|---------|--------|------------|
| `fake_lag_editor:set_callback(update_fake_lag_menu, true)` | 3655 | Switch state change | `update_fake_lag_menu()` | CONFIRMED |
| `fake_lag_editor_mode:set_callback(update_fake_lag_menu, true)` | 3718 | Combo change | `update_fake_lag_menu()` | CONFIRMED |
| `slot_0_94_18.fake_lag_editor:set_callback(update_fake_lag_menu, true)` | 3718 | Switch change | `update_fake_lag_menu()` | CONFIRMED |
| `slot_0_94_18.fake_lag_editor_mode:set_callback(update_fake_lag_menu, true)` | 3718 | Combo change | `update_fake_lag_menu()` | CONFIRMED |
| `slot_0_94_18.fake_lag_editor:set_callback(...)` | 3718 | (Duplicate registration) | `update_fake_lag_menu()` | LOW — Duplicate |

========================================
4. STATE OWNERSHIP MAP
========================================

| State Variable | Owner | Line | Shared With | Confidence |
|----------------|-------|------|-------------|------------|
| `slot_0_67_5` (int 3) | `slot_0_68_5` list | 1054 | Used as dependency for many UI elements | CONFIRMED |
| `slot_0_68_5` (list) | Multiple dependents | 1055 | Used as dependency for ~20 UI elements | CONFIRMED |
| `slot_0_83_6` (misc switch container) | Multiple switches | 3533 | Parent for `lagcomp_delay`, `fake_lag_editor`, etc. | CONFIRMED |
| `slot_0_94_18` (exploits table) | Multiple fake_lag settings | 3552 | `fake_lag_editor`, `lerp_editor`, etc. | CONFIRMED |
| `slot_0_76_7` (state table) | Defensive state settings | 2172 | `slot_0_76_7.settings[arg_64_0]` | CONFIRMED |
| `slot_0_82_1` (active state) | Defensive state tracking | ~8650 | `active`, `active2`, `ticks` fields | CONFIRMED |

========================================
4. DEPENDENCY GRAPH (CONFIRMED)
================================

```
slot_0_1_0 (neverlose UI library)
├── slot_0_61_2.misc (misc category container)
│   ├── slot_0_83_6 (exploits switch container)
│   │   ├── slot_0_94_18.lagcomp_delay (switch)
│   │   ├── slot_0_94_18.fake_lag_editor (switch)
│   │   │   ├── slot_0_94_18.fake_lag_editor_gear (combo)
│   │   │   ├── slot_0_94_18.fake_lag_default_limit (slider)
│   │   │   └── ...
│   └── slot_0_99_23.enabled (drink switch)
│
├── slot_0_78_7 (antiaim angles category)
│   ├── slot_0_79_9 (fake_duck switch)
│   └── slot_0_80_6 (leg_movement switch)
│
└── slot_0_86_10 (categories list)
    ├── slot_0_93_17 (Exploits)
    ├── slot_0_88_12 (Aimbot)
    ├── slot_0_90_14 (Movement & Animation)
    └── slot_0_91_15 (Extras)
```

========================================
4. STATE CONFLICTS
========================================

| # | Variable | Used By | Conflict Risk | Evidence |
|---|----------|---------|-------------|----------|
| 1 | `slot_0_68_5` | `slot_0_93_17` (categories list), `slot_0_67_5` (value 3) | Lines 1054-1055 | HIGH | Both used as dependencies for UI elements; if `slot_0_68_5` changes, all dependent UI elements change |
| 2 | `slot_0_67_5` | `slot_0_68_5` list dependency, `slot_0_68_5` itself | Lines 1054-1055 | HIGH | `slot_0_67_5` is both a value (3) and used as a dependency key |
| 3 | `slot_0_94_18.fake_lag_editor` | `slot_0_94_18.fake_lag_editor_mode`, `slot_0_94_18.fake_lag_default_limit`, etc. | Lines 3555-3576 | MEDIUM | Multiple settings depend on the same switch; if the switch is disabled, all dependent settings become invisible but retain their values |

========================================
END OF PREDICTION_PIPELINE.md