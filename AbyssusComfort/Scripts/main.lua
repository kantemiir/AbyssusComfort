-- AbyssusComfort: motion-sickness reduction for Abyssus (UE4SS Lua mod).
-- Client-side visual tweaks only. Config: ../config.lua
-- Keys: F6 reload config, F7 master toggle, F2/F3/F4/F5 quick A/B toggles.

local MOD = "AbyssusComfort"
local POLL_MS = 1000

local function log(fmt, ...)
    print(string.format("[%s] " .. fmt .. "\n", MOD, ...))
end

local seen_errors = {}
local function safe(name, f, ...)
    local ok, err = xpcall(f, debug.traceback, ...)
    if not ok then
        local msg = name .. ": " .. tostring(err)
        if not seen_errors[msg] then
            seen_errors[msg] = true
            log("ERROR %s", msg)
        end
    end
end

-- ---------------------------------------------------------------- config
local DEFAULTS = {
    Enabled = true,
    ArmsLean = 0.0,
    ArmsWrist = 1.0,
    ArmsRunBob = 0.0,
    ArmsFireAnim = 0.0,
    ArmsSway = 0.0,
    WeaponRecoilVisual = 0.0,
    CameraSway = 0.0,
    DisableHeadBob = false,
    ViewmodelFOV = 75,
    BlockCameraShakes = false,
    ShowIndicator = true,
}

local src = debug.getinfo(1, "S").source:gsub("^@", "")
local mod_dir = src:match("^(.*)[/\\]Scripts[/\\][^/\\]+$") or "."
local cfg = {}

local function load_config()
    local merged = {}
    for k, v in pairs(DEFAULTS) do merged[k] = v end
    local chunk, err = loadfile(mod_dir .. "\\config.lua")
    if not chunk then
        log("config.lua not loaded (%s), using defaults", tostring(err))
    else
        local ok, user = pcall(chunk)
        if ok and type(user) == "table" then
            for k in pairs(DEFAULTS) do
                if user[k] ~= nil then merged[k] = user[k] end
            end
            if user.ViewmodelFOV == nil then merged.ViewmodelFOV = nil end -- nil = keep vanilla
        else
            log("config.lua error: %s", tostring(user))
        end
    end
    cfg = merged
end

-- ---------------------------------------------------------------- helpers
local vanilla = {}   -- original values, keyed by object+property
local applied = {}   -- object -> settings signature already applied

local function try(f)
    local ok, v = pcall(f)
    if ok then return v end
    return nil
end

local function base_num(obj, key, prop)
    local k = key .. "|" .. prop
    if vanilla[k] == nil then
        local v = try(function() return obj[prop] end)
        if type(v) ~= "number" then return nil end
        vanilla[k] = v
    end
    return vanilla[k]
end

local function set_num(obj, key, prop, fn)
    local b = base_num(obj, key, prop)
    if b == nil then return false end
    local nv = fn(b)
    return pcall(function() obj[prop] = nv end)
end

local FIELDS = { "X", "Y", "Z", "Pitch", "Yaw", "Roll", "Min", "Max" }

local function scale_struct(obj, key, prop, factor)
    local s = try(function() return obj[prop] end)
    if s == nil or type(s) == "number" or type(s) == "boolean" then return false end
    local k = key .. "|" .. prop
    if vanilla[k] == nil then
        local base = {}
        for _, n in ipairs(FIELDS) do
            local v = try(function() return s[n] end)
            if type(v) == "number" then base[n] = v end
        end
        vanilla[k] = base
    end
    local any = false
    for n, v in pairs(vanilla[k]) do
        any = true
        pcall(function() s[n] = v * factor end)
    end
    return any
end

local function factor(v)
    if not cfg.Enabled then return 1.0 end
    return v
end

local function signature()
    return table.concat({
        tostring(cfg.Enabled), tostring(cfg.ArmsSway), tostring(cfg.ArmsLean), tostring(cfg.ArmsWrist),
        tostring(cfg.ArmsRunBob), tostring(cfg.ArmsFireAnim),
        tostring(cfg.WeaponRecoilVisual), tostring(cfg.CameraSway), tostring(cfg.DisableHeadBob),
        tostring(cfg.ViewmodelFOV),
    }, "|")
end

-- ---------------------------------------------------------------- indicator
local function flash(good)
    if not cfg.ShowIndicator then return end
    local pc = FindFirstOf("PlayerController")
    if not pc or not pc:IsValid() then return end
    local pcm = try(function() return pc.PlayerCameraManager end)
    if pcm and pcm:IsValid() then
        local c = good and { R = 0.1, G = 0.95, B = 0.3, A = 1.0 } or { R = 0.95, G = 0.15, B = 0.1, A = 1.0 }
        pcall(function() pcm:StartCameraFade(0.45, 0.0, 0.6, c, false, false) end)
    end
end

-- ---------------------------------------------------------------- anim graph nodes
-- Alpha of an AnimNode struct inside an anim instance (0 = node has no effect, 1 = vanilla).
-- Strafe lean of the gun/arms is driven by ModifyBone_2 (bone ik_hand_gun: lateral shift + roll).
-- ModifyBone_1 (ik_hand_gun) is the visual recoil kick; ModifyBone (hand_l) is the left wrist twist.
local function set_node_alpha(inst, key, node, alpha)
    local ok = pcall(function()
        local n = inst[node]
        local k = key .. "|" .. node .. ".Alpha"
        if vanilla[k] == nil then vanilla[k] = n.Alpha end
        n.Alpha = alpha * vanilla[k]
    end)
    return ok and try(function() return inst[node].Alpha end)
end

-- For nodes whose Alpha is re-driven by the game every frame (run additive, fire blend),
-- scale the final weight through AlphaScaleBias.Scale instead.
local function set_node_scale(inst, key, node, f)
    local ok = pcall(function()
        local sb = inst[node].AlphaScaleBias
        local k = key .. "|" .. node .. ".SB.Scale"
        if vanilla[k] == nil then vanilla[k] = sb.Scale end
        sb.Scale = f * vanilla[k]
    end)
    return ok and try(function() return inst[node].AlphaScaleBias.Scale end)
end

-- ---------------------------------------------------------------- slow appliers
local function apply_arms(sig)
    local list = FindAllOf("RArmsAnimInstance")
    if not list then return end
    for _, o in ipairs(list) do
        if o:IsValid() and try(function() return o.IsLocallyControlled end) ~= false then
            local key = o:GetFullName()
            if applied[key] ~= sig then
                local fl = factor(cfg.ArmsLean)
                local fw = factor(cfg.ArmsWrist)
                local fs = factor(cfg.ArmsSway)
                local fr = factor(cfg.WeaponRecoilVisual)
                local fb = factor(cfg.ArmsRunBob)
                local ff = factor(cfg.ArmsFireAnim)
                local a3 = set_node_alpha(o, key, "AnimGraphNode_ModifyBone_1", fr)
                local a1 = set_node_alpha(o, key, "AnimGraphNode_ModifyBone_2", fl)
                local a2 = set_node_alpha(o, key, "AnimGraphNode_ModifyBone", fw)
                local a4 = set_node_scale(o, key, "AnimGraphNode_ApplyAdditive_2", fb)
                local a5 = set_node_scale(o, key, "AnimGraphNode_TwoWayBlend", ff)
                scale_struct(o, key, "OffsetDistanceScale", fs)
                scale_struct(o, key, "OffsetAngleScale", fs)
                set_num(o, key, "MaxOffsetDistance", function(v) return v * fs end)
                applied[key] = sig
                log("arms: lean x%.2f (%s) recoil x%.2f (%s) runBob x%.2f (%s) fireAnim x%.2f (%s) sway x%.2f",
                    fl, tostring(a1), fr, tostring(a3), fb, tostring(a4), ff, tostring(a5), fs)
            end
        end
    end
end

local function find_local_pawn()
    local list = FindAllOf("RPlayerPawn")
    if not list then return nil end
    local first
    for _, p in ipairs(list) do
        if p:IsValid() then
            first = first or p
            if try(function() return p:IsLocallyControlled() end) == true then return p end
        end
    end
    return first
end

local function apply_pawn(sig)
    local pawn = find_local_pawn()
    if not pawn then return end
    local key = pawn:GetFullName()
    if applied[key] == sig then return end
    local first_time = (applied[key] == nil)

    if cfg.ViewmodelFOV ~= nil or vanilla[key .. "|FirstPersonModelFOV"] ~= nil then
        set_num(pawn, key, "FirstPersonModelFOV", function(v)
            if cfg.Enabled and cfg.ViewmodelFOV then return cfg.ViewmodelFOV end
            return v
        end)
    end

    local fs = factor(cfg.CameraSway)
    set_num(pawn, key, "MaxSwayDegree", function(v) return v * fs end)

    local rig = try(function() return pawn.CameraRigSkeleton end)
    local rig_ok = false
    if rig and rig:IsValid() then
        rig_ok = set_num(rig, key .. "|rig", "GlobalAnimRateScale", function(v)
            if cfg.Enabled and cfg.DisableHeadBob then return 0.0 end
            return v
        end)
    end

    applied[key] = sig
    log("pawn applied: viewmodelFOV=%s (now %s) camSway x%.2f headBobOff=%s rig=%s",
        tostring(cfg.Enabled and cfg.ViewmodelFOV or "vanilla"),
        tostring(try(function() return pawn.FirstPersonModelFOV end)), fs,
        tostring(cfg.Enabled and cfg.DisableHeadBob), tostring(rig_ok))
    if first_time then flash(cfg.Enabled) end
end

local function apply_all()
    local sig = signature()
    safe("apply_arms", apply_arms, sig)
    safe("apply_pawn", apply_pawn, sig)
end

local function stop_shakes()
    local pcm = FindFirstOf("PlayerCameraManager")
    if pcm and pcm:IsValid() then
        pcall(function() pcm:StopAllCameraShakes(true) end)
    end
end

-- ---------------------------------------------------------------- startup
load_config()
log("loaded v0.5. Enabled=%s Lean=%.2f RunBob=%.2f FireAnim=%.2f Recoil=%.2f Sway=%.2f CameraSway=%.2f HeadBobOff=%s ViewmodelFOV=%s",
    tostring(cfg.Enabled), cfg.ArmsLean, cfg.ArmsRunBob, cfg.ArmsFireAnim, cfg.WeaponRecoilVisual,
    cfg.ArmsSway, cfg.CameraSway, tostring(cfg.DisableHeadBob), tostring(cfg.ViewmodelFOV))

LoopAsync(POLL_MS, function()
    ExecuteInGameThread(apply_all)
    return false
end)

LoopAsync(100, function()
    if cfg.Enabled and cfg.BlockCameraShakes then ExecuteInGameThread(function() safe("shakes", stop_shakes) end) end
    return false
end)

local function toggle_key(key, name, field, reduced, full, also)
    RegisterKeyBind(key, function()
        if cfg[field] == reduced then cfg[field] = full else cfg[field] = reduced end
        local is_reduced = (cfg[field] == reduced)
        for _, f in ipairs(also or {}) do cfg[f] = cfg[field] end
        log("%s: %s = %s", name, field, tostring(cfg[field]))
        ExecuteInGameThread(function()
            apply_all()
            flash(is_reduced)
        end)
    end)
end

toggle_key(Key.F2, "gun/arms strafe lean (A/D)", "ArmsLean", 0.0, 1.0)
toggle_key(Key.F3, "arms run/jump bob", "ArmsRunBob", 0.0, 1.0)
toggle_key(Key.F4, "arms mouse-turn sway", "ArmsSway", 0.0, 1.0)
toggle_key(Key.F5, "weapon recoil animation", "WeaponRecoilVisual", 0.0, 1.0, { "ArmsFireAnim" })

RegisterKeyBind(Key.F6, function()
    load_config()
    log("config reloaded")
    ExecuteInGameThread(function() apply_all() flash(true) end)
end)

RegisterKeyBind(Key.F7, function()
    cfg.Enabled = not cfg.Enabled
    log("Enabled = %s", tostring(cfg.Enabled))
    ExecuteInGameThread(function() apply_all() flash(cfg.Enabled) end)
end)
