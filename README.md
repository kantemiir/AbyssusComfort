# AbyssusComfort

**RU** · [EN](#english)

Мод для **Abyssus** (Steam, Windows), который убирает основные причины укачивания в режиме от первого лица: наклон и «улёт» оружия на A/D, тряску рук в прыжке, визуальную отдачу и инерцию оружия при поворотах мыши. Каждый эффект настраивается от 0 до 1.

> ⚠️ **Бета.** Сделан одним человеком и проверялся на одном компьютере. Это клиентская визуальная правка анимации, на урон и разброс она не влияет, но игра использует онлайн-сервисы (EOS, кроссплей), а правила разработчиков по модам не проверены. Используйте **в одиночной игре / офлайн и на свой риск**. Проект не связан с разработчиками Abyssus.

## Что умеет

| Параметр в `config.lua` | Что убирает | По умолчанию |
|---|---|---|
| `ArmsLean` | Наклон и боковой сдвиг оружия/рук при A/D и вертикальный при прыжке | `0.0` (убрано) |
| `ArmsRunBob` | Анимацию бега у рук. Игра включает её на полную силу и при **прыжке**, отсюда сильная тряска в воздухе | `0.0` |
| `ArmsSway` | Инерцию оружия/рук при движении мышью | `0.0` |
| `WeaponRecoilVisual` | Визуальный откат оружия при стрельбе (разброс и урон **не** меняются) | `0.0` |
| `ArmsFireAnim` | Смену позы рук при стрельбе | `0.0` |
| `ViewmodelFOV` | FOV модели рук/оружия (в игре 90). Меньше = меньше искажение оружия по краям. `nil` = не менять | `75` |
| `CameraSway` | Крен/раскачку камеры игрока | `0.0` |
| `DisableHeadBob` | Анимацию камеры (head bob, тряска при приземлении) | `false` |
| `BlockCameraShakes` | Гасить все тряски камеры (экспериментально) | `false` |
| `ShowIndicator` | Зелёная/красная вспышка экрана при включении мода | `true` |

`1.0` = как в оригинале, `0.0` = убрано полностью, любое число между — доля оригинального эффекта.

**Клавиши в игре:** `F6` перечитать `config.lua` (применяется сразу, перезапуск не нужен) · `F7` мод вкл/выкл (зелёная/красная вспышка) · `F2` наклон при A/D · `F3` тряска бега/прыжка · `F4` инерция мыши · `F5` отдача (быстрое вкл/выкл для сравнения).

## Установка

1. Скачайте **UE4SS** (сборка `experimental-latest`, `UE4SS_v3.0.1-…zip`, нужна версия с поддержкой UE 5.4+) со страницы релизов: <https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest>.
2. Распакуйте архив в `…\steamapps\common\Abyssus\RGame\Binaries\Win64\` так, чтобы рядом с `RGame-Win64-Shipping.exe` лежали `dwmapi.dll` и папка `ue4ss`.
3. Скопируйте папку **`AbyssusComfort`** из этого репозитория в `…\Win64\ue4ss\Mods\`.
4. Включите мод: либо оставьте файл `enabled.txt` внутри папки мода (он уже лежит), либо добавьте строку `AbyssusComfort : 1` в `ue4ss\Mods\mods.txt`.
5. Запустите игру. При входе в забег экран коротко мигнёт **зелёным**: мод работает.

**Удаление:** удалите папку `AbyssusComfort` из `Mods`. Чтобы убрать и UE4SS, удалите `dwmapi.dll` и папку `ue4ss`.

## Как это устроено и что проверено

Мод (UE4SS, Lua) раз в секунду находит анимацию рук игрока и меняет прозрачность (`Alpha`/`AlphaScaleBias`) нескольких узлов её графа: кость оружия `ik_hand_gun` (наклон и отдача) и слой аддитивной анимации бега. Положения камеры, регистрация попаданий и урон не затрагиваются.

- ✅ Проверено автором: `ArmsLean` (A/D) — тряска ушла.
- ⚠️ **Тряска в прыжке:** по отзыву автора после v0.5 она **сохраняется**. Анимация бега у рук в воздухе гасится (`ArmsRunBob`), но этого недостаточно, причина ещё выясняется, исправление планируется в следующей версии.
- ⏳ Включено, но пока не проверено: `WeaponRecoilVisual`/`ArmsFireAnim` (отдача), `ArmsSway` (мышь), влияние `ViewmodelFOV` на отрисовку.
- Проверялся персонаж *Ricky*. Остальные персонажи, судя по базовому классу, должны вести себя так же, но это не подтверждено.
- После обновления игры названия узлов могут измениться. В этом случае мод молча перестанет действовать (ошибок и вылетов он не вызывает, в `UE4SS.log` будут записи).

Если у вас осталась тряска, приложите `ue4ss\UE4SS.log` и опишите, что именно (A/D, прыжок, мышь, стрельба) в Issues.

## Лицензия

MIT, см. [LICENSE](LICENSE). UE4SS — отдельный проект (MIT) и в этот репозиторий не входит.

---

<a name="english"></a>
## English

**AbyssusComfort** is a mod for **Abyssus** (Steam, Windows) that removes the main motion-sickness triggers in first person: weapon/arm lean when strafing (A/D), arm shaking while jumping, visual recoil and mouse-turn weapon sway. Every effect is adjustable from 0 to 1.

> ⚠️ **Beta.** One author, tested on a single PC. It only changes client-side animation (no damage/spread change), but the game uses online services (EOS, crossplay) and the developers' modding policy has not been checked. Use in **solo / offline play, at your own risk**. Not affiliated with the Abyssus developers.

### Settings (`config.lua`)

`1.0` = vanilla, `0.0` = removed, anything in between = fraction of the original effect.

| Option | Removes | Default |
|---|---|---|
| `ArmsLean` | Gun/arm tilt and lateral shift on A/D, vertical shift on jump | `0.0` |
| `ArmsRunBob` | Arms run animation. The game plays it at full strength when you **jump**, which causes violent shaking in the air | `0.0` |
| `ArmsSway` | Weapon/arm inertia when moving the mouse | `0.0` |
| `WeaponRecoilVisual` | Visual weapon kick when shooting (does **not** change spread or damage) | `0.0` |
| `ArmsFireAnim` | Arm pose change while firing | `0.0` |
| `ViewmodelFOV` | FOV of the arms/weapon model (game uses 90); `nil` = leave unchanged | `75` |
| `CameraSway` | Player camera roll/sway | `0.0` |
| `DisableHeadBob` | Camera rig animation (head bob, landing shake) | `false` |
| `BlockCameraShakes` | Stop all camera shakes (experimental) | `false` |
| `ShowIndicator` | Green/red screen flash when the mod activates | `true` |

**In-game keys:** `F6` reload `config.lua` (instant) · `F7` mod on/off (green/red flash) · `F2` strafe lean · `F3` run/jump bob · `F4` mouse sway · `F5` recoil (quick A/B toggles).

### Installation

1. Download **UE4SS** `experimental-latest` (`UE4SS_v3.0.1-….zip`, needs UE 5.4+ support): <https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest>.
2. Extract it into `…\steamapps\common\Abyssus\RGame\Binaries\Win64\` so that `dwmapi.dll` and the `ue4ss` folder sit next to `RGame-Win64-Shipping.exe`.
3. Copy the **`AbyssusComfort`** folder from this repository into `…\Win64\ue4ss\Mods\`.
4. Enable it: keep the included `enabled.txt` in the mod folder, or add `AbyssusComfort : 1` to `ue4ss\Mods\mods.txt`.
5. Start the game. When a run starts the screen flashes **green** briefly: the mod is active.

**Uninstall:** delete the `AbyssusComfort` folder from `Mods` (and `dwmapi.dll` + `ue4ss` to remove UE4SS).

### Status

- ✅ Verified by the author: `ArmsLean` (A/D shaking is gone).
- ⚠️ **Jump shaking:** per the author's testing it is **still present** after v0.5. The arms run animation in the air is suppressed (`ArmsRunBob`) but that is not enough; the cause is still being investigated and a fix is planned for the next version.
- ⏳ Shipped but not yet verified: `WeaponRecoilVisual`/`ArmsFireAnim` (recoil), `ArmsSway` (mouse), effect of `ViewmodelFOV`.
- Tested with the *Ricky* character only. After a game update the node names may change; the mod then simply stops having an effect (it logs to `UE4SS.log` instead of crashing).

### License

MIT, see [LICENSE](LICENSE). UE4SS is a separate MIT-licensed project and is not included here.
