-- Флаг третьего лица
local thirdPersonEnabled = false

-- Настройки камеры
local thirdPersonDistance = 100
local thirdPersonHeight = 10
local thirdPersonAngle = 0

-- Функция переключения вида
local function ToggleThirdPerson()
    thirdPersonEnabled = not thirdPersonEnabled
    if thirdPersonEnabled then
        notification.AddLegacy("Вы включили третье лицо", NOTIFY_HINT, 3)
        surface.PlaySound("buttons/button3.wav") -- Звук при включении
    else
        notification.AddLegacy("Вы выключили третье лицо", NOTIFY_HINT, 3)
        surface.PlaySound("buttons/button2.wav") -- Звук при выключении
    end
end

-- Бинд на клавишу "V" для переключения
hook.Add("PlayerButtonDown", "ThirdPersonToggle", function(ply, button)
    if button == KEY_V then -- Меняем на клавишу "V"
        ToggleThirdPerson()
    end
end)

-- Хук для изменения камеры
hook.Add("CalcView", "ThirdPersonCalcView", function(ply, pos, angles, fov)
    if not thirdPersonEnabled or not IsValid(ply) then
        return
    end

    -- Параметры третьего лица
    local view = {}
    view.origin = pos - angles:Forward() * thirdPersonDistance + Vector(0, 0, thirdPersonHeight) -- Позиция камеры
    view.angles = angles + Angle(0, thirdPersonAngle, 0) -- Угол камеры
    view.fov = fov -- Поле зрения
    view.drawviewer = true -- Показываем модель игрока

    -- Проверка на препятствия между камерой и игроком
    local tr = util.TraceLine({
        start = pos,
        endpos = view.origin,
        filter = ply
    })

    if tr.Hit then
        view.origin = tr.HitPos + tr.HitNormal * 5 -- Корректируем положение камеры
    end

    return view
end)

-- Хук для отображения модели игрока
hook.Add("ShouldDrawLocalPlayer", "ThirdPersonDrawPlayer", function(ply)
    return thirdPersonEnabled -- Показываем модель игрока в третьем лице
end)
