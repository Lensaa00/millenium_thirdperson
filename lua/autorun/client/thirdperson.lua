-- Флаг третьего лица
local thirdPersonEnabled = false

-- Настройки камеры
local thirdPersonDistance = 70 -- Дистанция назад
local thirdPersonHeight = 1 -- Высота камеры
local thirdPersonX = 25 -- Смещение по оси X
local thirdPersonAngle = 2 -- Дополнительный угол

local lastChange = CurTime()
local delay = 1

-- Функция переключения вида
local function ToggleThirdPerson()
    if not LocalPlayer():Alive() then return end
    if CurTime() - lastChange >= delay then
        lastChange = CurTime()
        thirdPersonEnabled = not thirdPersonEnabled
        if thirdPersonEnabled then
            notification.AddLegacy("Третье лицо включено", NOTIFY_HINT, 2)
        else
            notification.AddLegacy("Третье лицо выключено", NOTIFY_HINT, 2)
        end
    end
end

-- Бинд на клавишу "V" для переключения
hook.Add("PlayerButtonDown", "ThirdPersonToggle", function(ply, button)
    if button == KEY_T then -- Меняем на клавишу "V"
        ToggleThirdPerson()
    end
end)

-- Хук для изменения камеры
hook.Add("CalcView", "ThirdPersonCalcView", function(ply, pos, angles, fov)
    if not thirdPersonEnabled or not IsValid(ply) or not ply:Alive() then
        thirdPersonEnabled = false
        return
    end

    -- Параметры третьего лица
    local right = angles:Right() -- Вектор направления вправо от взгляда игрока
    local forward = angles:Forward() -- Вектор направления вперед от взгляда игрока

    -- Расчет позиции камеры с учетом смещения
    local view = {}
    view.origin = pos
        - forward * thirdPersonDistance -- Смещение назад
        + right * thirdPersonX -- Смещение вправо/влево
        + Vector(0, 0, thirdPersonHeight) -- Смещение вверх
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
