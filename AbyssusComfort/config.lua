-- AbyssusComfort configuration / Настройки AbyssusComfort
-- Edit values, save, then press F6 in game to apply instantly (no restart needed).
-- Меняйте значения, сохраняйте файл и нажмите F6 в игре — настройки применятся сразу.
--
-- Multipliers: 1.0 = vanilla (как в оригинале), 0.0 = effect fully removed (эффект убран).
-- Any value between works, e.g. 0.3 = 30% of the original effect.
--
-- In-game keys / Клавиши в игре:
--   F6 reload this file / перечитать файл
--   F7 mod on/off (green/red flash) / мод вкл/выкл (зелёная/красная вспышка)
--   F2 strafe lean, F3 run/jump bob, F4 mouse-turn sway, F5 recoil: quick on/off for comparison
--   F2 наклон при A/D, F3 тряска при беге/прыжке, F4 инерция при поворотах мыши, F5 отдача

return {
    -- Master switch. / Общий выключатель.
    Enabled = true,

    -- Show a short green/red screen flash when the mod activates or is toggled.
    -- Короткая зелёная/красная вспышка экрана при включении/переключении мода.
    ShowIndicator = true,

    -- Gun/arms tilt and lateral shift when pressing A/D (strafe lean) and when jumping.
    -- Наклон и сдвиг оружия/рук при нажатии A/D (и вертикальный при прыжке).
    ArmsLean = 0.0,

    -- Arms run animation. The game also plays it at full strength when you JUMP, which causes
    -- violent arm shaking in the air; this removes it.
    -- Анимация бега у рук. Игра включает её на полную мощность и при ПРЫЖКЕ, из-за чего руки
    -- сильно трясутся в воздухе; этот параметр её убирает.
    ArmsRunBob = 0.0,

    -- Weapon/arms inertia when you move the mouse (sway while turning).
    -- Инерция оружия/рук при движении мыши (раскачка при поворотах).
    ArmsSway = 0.0,

    -- Visual recoil kick of the weapon and arms when shooting. Does NOT change aim spread or damage.
    -- Визуальная отдача оружия и рук при стрельбе. На разброс и урон НЕ влияет.
    WeaponRecoilVisual = 0.0,

    -- Extra arm pose change while firing (blend into the "fire" pose).
    -- Дополнительная смена позы рук при стрельбе.
    ArmsFireAnim = 0.0,

    -- Left-wrist twist that follows strafing (no visible effect in testing, kept for completeness).
    -- Скручивание левой кисти при стрейфе (в тестах без видимого эффекта).
    ArmsWrist = 1.0,

    -- Camera roll/sway multiplier (BP_RPlayerPawn MaxSwayDegree).
    -- Крен/раскачка камеры.
    CameraSway = 0.0,

    -- true = freeze the camera rig animation (head bob, landing/dash camera movement).
    -- true = отключить анимацию камеры (head bob, тряска при приземлении и рывке).
    DisableHeadBob = false,

    -- Field of view of the arms/weapon model (vanilla = 90). Lower = less edge distortion on the weapon.
    -- Set to nil to keep the game's value. World FOV is still set in the game's own menu.
    -- FOV модели рук/оружия (в оригинале 90). Меньше = меньше искажение по краям.
    -- nil = не менять. FOV мира по-прежнему настраивается в меню игры.
    ViewmodelFOV = 75,

    -- Stop all camera shakes every 0.1 s (explosions, hits). Experimental.
    -- Гасить все тряски камеры (взрывы, удары). Экспериментально.
    BlockCameraShakes = false,
}
