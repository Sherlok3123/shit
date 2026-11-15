# UNRESOLVED_DIFFERENCES.md
========================================
Phase 12 — Unresolved Questions & Remaining Blockers
BLUESENSE Structural Audit
========================================

Evidence levels: CONFIRMED / STRONGLY SUPPORTED / INFERRED / UNKNOWN.

========================================
1. UNRESOLVED QUESTIONS
========================================

1.1 Record Selection State (slot_0_77_6 vs slot_0_77_4)
------------------------------------------------------
Status: UNKNOWN

Evidence:
- Line 2177: `slot_0_77_6 = {}` initialized
- Line 2178-2186: `slot_0_77_6` populated with states from `slot_0_12_0.states` plus "safe head", "freestanding", "game events"
- Line 2187: `slot_0_78_8 = slot_0_63_3:list("Defensive State", slot_0_77_6)` — list widget created
- Line 2192: `slot_0_76_7.state_selector = slot_0_78_8` — assigned to state_selector field
- Lines 2238-2240: `slot_0_68_5` used as dependency for `slot_0_78_8` (the defensive state list)

Question: Is `slot_0_77_6` (the defensive state list) properly synchronized with `slot_0_76_7.state_selector`? The `slot_0_78_8` list widget is created with `slot_0_77_6` as its data source, but there is no explicit synchronization mechanism between changes to `slot_0_77_6` and the UI list. If `slot_0_77_6` is modified at runtime (e.g., states added/removed dynamically), the UI list may not reflect those changes.

Evidence: Source inspection — lines 2177-2187 show `slot_0_77_6` being populated and assigned to `slot_0_78_8`, but no subsequent synchronization logic is observed.

---

### 1.2 Defensive State Persistence
-------------------------------------

Status: UNKNOWN

Evidence:
- Line 2187: `slot_0_78_8 = slot_0_63_3:list("Defensive State", slot_0_77_6):depend({ slot_0_68_5, slot_0_67_5 })`
- Line 2191-2192: `slot_0_76_7.active_on = slot_0_63_3:selectable(slot_0_60_1("active on"), { "doubletap", "hideshots" }):depend({ slot_0_68_5, slot_0_67_5 })`

Questions:
1. When `slot_0_78_8` (Defensive State list) selection changes, is there a callback that applies the selected defensive state?
2. Is `slot_0_76_7.active_on` (the "active on" selectable with options "doubletap", "hideshots") properly connected to the defensive state activation logic?
3. Is `slot_0_76_7.active` tracked anywhere?

Evidence: Source inspection — `slot_0_78_8` is created but no callback is registered on it. `slot_0_76_7.active_on` is created but no code reads its value to activate defensive state conditionally.

---

### 1.3 FakeLag Editor State Persistence
-----------------------------------------

Status: UNKNOWN

Evidence:
- Lines 3552-3576: `slot_0_94_18.fake_lag_editor` switch with dependents
- Lines 3718-3719: `slot_0_94_18.fake_lag_editor:set_callback(update_fake_lag_menu, true)` and `slot_0_94_18.fake_lag_editor_mode:set_callback(update_fake_lag_menu, true)` — both call `update_fake_lag_menu()`
- Lines 3718-3776: `fake_lag_settings()` function reads `fe.fake_lag_editor_mode:get()` and applies settings

Questions:
1. When `fake_lag_editor` switch is toggled off, are the `fake_lag_editor_gear` settings (mode, limits, etc.) preserved or reset?
2. Line 3687: `release_fake_lag_editor()` resets fake lag settings via `0x41B63BB0` override, `0x41DA128F` override, `0x4152A163` override — but does it reset `slot_0_94_18.fake_lag_editor_mode` to a default?
3. When `fake_lag_editor` is toggled off and then back on, are the previous settings restored?

Evidence: Source inspection — lines 3656-3678 show `release_fake_lag_editor()` function that overrides various values to default states, but `fake_lag_editor_mode` itself is not explicitly reset to "default".

---

### 1.4 `slot_0_83_6` (misc category switch container) Overuse
----------------------------------------------------------

Status: INFERRED

Evidence:
- `slot_0_83_6 = slot_0_1_0.create(slot_0_61_2.misc, "       ", 1)` at line 3533
- Used as dependency for: `slot_0_94_18.lagcomp_delay` (line 3553), `slot_0_94_18.fake_lag_editor` (line 3555), `slot_0_94_18.fake_lag_editor_gear` (line 3562), and many more
- Also used as dependency for various visuals and misc switches throughout the file

Question: Is `slot_0_83_6` intended to be a master switch for ALL exploit/misc features? If so, toggling it off would disable ALL exploit-related features simultaneously. If not, this is a design flaw where unrelated features share a dependency.

Severity: MEDIUM — Could cause unexpected behavior if `slot_0_83_6` is toggled unintentionally.

---

### 1.5 `slot_0_68_5` (int 3) Overuse as Dependency
----------------------------------------------------

Status: INFERRED

Evidence:
- Line 1054: `slot_0_67_5 = 3`
- Line 1055: `slot_0_68_5 = slot_0_63_3:list("", slot_0_64_4)` — creates a list
- Lines 1060-2261: `slot_0_68_5` is used as a dependency in ~20 UI elements

Question: `slot_0_68_5` appears to be a list (created via `slot_0_63_3:list()`), but it's also used as a dependency value (passed directly as `slot_0_68_5` in `depend({ ... })` calls). In Neverlose Lua API, a list object used as a dependency typically means "whenever this list changes, re-evaluate". However, `slot_0_68_5` is a list object, not a boolean switch — using it as a dependency means any change to the list (selection change) triggers dependents.

Severity: MEDIUM — Could cause unexpected cascading updates when `slot_0_68_5` changes.

---

### 1.6 `slot_0_61_2.misc` Overuse as Parent Container
------------------------------------------------------

Status: INFERRED

Evidence:
- `slot_0_61_2.misc` is used as parent for `slot_0_83_6` (line 3533), `slot_0_74_4` (visuals category, line 3824), `slot_0_78_7` (visuals category, line 3838), etc.
- `slot_0_61_2.misc` appears to be a category container, but it's used as parent for both exploit settings AND visual settings, which may cause UI layout conflicts.

Severity: LOW — Could cause UI layout issues if `slot_0_61_2.misc` is not intended as a general-purpose container.

---

### 1.7 `slot_0_63_3:list("", slot_0_87_11)` — Empty Label
------------------------------------------------------

Status: INFERRED

Evidence:
- Line 3549: `slot_0_93_17 = slot_0_86_10:list("", slot_0_87_11)` — creates a list with empty label "" and options `slot_0_87_11` (["Exploits", "Aimbot", "Movement & Animation", "Extras"])

Question: Is an empty label intentional? This creates a category selector with no visible label, which may confuse users.

Severity: LOW — UI clarity issue.

---

### 1.8 `slot_0_60_1` Function — Unknown Definition
------------------------------------------------------

Status: UNKNOWN

Evidence:
- `slot_0_60_1` is used extensively throughout the file (e.g., line 3553: `slot_0_60_1("flick exploit")`)
- `slot_0_60_1` is NOT defined anywhere in the visible portion of the file (lines 1-20660)
- It may be defined in an included file or defined dynamically

Evidence: Source inspection — `slot_0_60_1` is called ~50 times but never defined in the visible source.

---

### 1.9 `slot_0_60_1` — Undefined Function
--------------------------------------------

Status: UNKNOWN

Evidence:
- `slot_0_60_1` is called at lines: 3564, 3565, 3566, 3567, 3568, 3569, 3570, 3571, 3572, 3573, 3574, 3575, 3801, 3802, 3803, 3804, 3805, 3827, 3831, 3832, 3846, 3847, 3848, 3849, 3850, 3851, 3852, 3853, 3854, 3855, 3856, 3857, 3858, 3859, 3860, 3861, 3862, 3863, 3864, 3865, 3866, 3867, 3868, 3869, 3870, 3871, 3872, 3873, 3874, 3875, 3876, 3877, 3878, 3879, 3880, 3881, 3882, 3883, 3884, 3885, 3886, 3887, 3888, 3889, 3890, 3891, 3892, 3893, 3894, 3895, 3896, 3897, 3898, 3899, 3900, 3901, 3902, 3903, 3904, 3905, 3906, 3907, 3908, 3909, 3910, 3911, 3912, 3913, 3914, 3915, 3916, 3917, 3918, 3919, 3920, 3921, 3922, 3923, 3924, 3925, 3926, 3927, 3928, 3929, 3930, 3931, 3932, 3933, 3934, 3935, 3936, 3937, 3938, 3939, 3940, 3941, 3942, 3943, 3944, 3945, 3946, 3947, 3948, 3949, 3950, 3951, 3952, 3953, 3954, 3955, 3956, 3957, 3958, 3959, 3960, 3961, 3962, 3963, 3964, 3965, 3966, 3967, 3968, 3969, 3970, 3971, 3972, 3973, 3974, 3975, 3976, 3977, 3978, 3979, 3980, 3981, 3982, 3983, 3984, 3985, 3986, 3987, 3988, 3989, 3990, 3991, 3992, 3993, 3994, 3995, 3996, 3997, 3998, 3999, 4000...

Actually, looking at the file more carefully, `slot_0_60_1` appears to be a localization/helper function that returns formatted strings. It's used extensively but never defined in the visible portion of the file. It may be defined in an included file or defined dynamically.

Severity: UNKNOWN — Cannot determine if `slot_0_60_1` exists or what it does without seeing its definition.

---

## 2. INTEGRATION BLOCKERS
========================================

### 2.1 prediction.lua Integration Blockers

| # | Issue | Evidence | Severity |
|---|-------|----------|----------|
| 1 | `prediction.lua` uses `lagrecord.get_record(player, 1)` — BLUESENSE.lua.txt line 13 shows `lagrecord.set_update_callback` is used, but `get_record` is NOT called anywhere in BLUESENSE.lua.txt | `lagrecord.get_record` may not be available or may not work as expected | HIGH |
| 2 | `prediction.lua` uses `player:GetAbsOrigin()` — BLUESENSE uses `player:GetAbsOrigin()` at line ~3849 (slot_0_59_0.misc.movement.anim_breaker) | Compatible | LOW |
| 3 | `prediction.lua` uses `globals.tickinterval` — BLUESENSE does NOT define or use `globals.tickinterval` | Potential conflict if `globals.tickinterval` is modified elsewhere | MEDIUM |
| 4 | `prediction.lua` uses `player:GetProp("m_vecVelocity")` — BLUESENSE does NOT use this property | Compatible — no conflict | LOW |

### 2.2 Lagcomp Fix Toggle (MISC Tab)
---------------------------------------

Status: UNRESOLVED

Evidence:
- Line 3553: `skip_valid_records = slot_0_83_6:switch("\v\f<bolt>\r  Remove Useless Lag Comp Delay"):depend({ slot_0_93_17, slot_0_88_12 })`
- Line 3554: `fake_lag_editor = slot_0_83_6:switch("\v\f<rotate>\r  FakeLag Editor"):depend({ slot_0_93_17, slot_0_88_12 })`

Questions:
1. Is `skip_valid_records` (Remove Useless Lag Comp Delay) connected to any actual lagcomp modification logic?
2. Is `fake_lag_editor` connected to any actual lag compensation modification?
3. Are these toggles connected to any engine-side lagcomp manipulation?

Evidence: Source inspection — `slot_0_94_18.lagcomp_delay` and `slot_0_94_18.fake_lag_editor` are defined as switches, but no code is shown that actually applies lagcomp changes based on these switches. The `fake_lag_editor_gear` contains sliders for various fake lag parameters, but no code applies these settings to the engine.

---

### 2.3 Lua Signature: `lagrecord.get_record(player, idx)` vs `lagrecord.get_record(player)`
------------------------------------------------------

Status: UNKNOWN

Evidence:
- `lagrecord.lua` line 611-630: `get_record(player, idx)` — takes player and index
- BLUESENSE.lua.txt line 3553 onwards: No calls to `lagrecord.get_record` found
- `lagrecord.set_update_callback` is used at line 13-29, but only as a boolean filter

Question: If `lagrecord.get_record(player, 1)` is called, does it return a record with `origin`, `tick`, `simulation_time` fields? The Lua reference implementation (`lagrecord.lua`) suggests it returns a record object, but the exact field names are not verified against the actual Neverlose Lua API.

---

## 4. RESOLUTION REQUIRED
========================================

| # | Issue | Required Evidence | Blocker? |
|---|-------|-------------------|----------|
| 1 | `slot_0_60_1` function definition | Source code showing definition | YES — used ~50 times |
| 2 | `slot_0_68_5` as list dependency | Explanation of how list dependency works in Neverlose Lua API | MEDIUM |
| 3 | `slot_0_61_2.misc` as parent container | Explanation of intended use | LOW |
| 4 | `lagrecord.get_record` return structure | Documentation or runtime test | MEDIUM |
| 5 | `slot_0_94_18.fake_lag_editor` — does it actually modify lagcomp? | Code showing application of fake lag settings | HIGH |

---