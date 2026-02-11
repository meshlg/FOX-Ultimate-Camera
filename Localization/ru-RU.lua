-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

if GetCVar("Language.2") ~= "ru" then return end

-- Main
ZO_CreateStringId("SI_FOXUC_ADDON_NAME", "FOX Ultimate Camera")
ZO_CreateStringId("SI_FOXUC_SLASH_COMMAND", "/foxuc")
ZO_CreateStringId("SI_FOXUC_MAIN_CATEGORY", "Основные параметры камеры")

-- Debug
ZO_CreateStringId("SI_FOXUC_DEBUG_TOGGLE", "Включить отладочный режим")
ZO_CreateStringId("SI_FOXUC_DEBUG_TOGGLE_TT", "Показывать отладочные сообщения в чате при смене вида камеры (от первого/третьего лица).")
ZO_CreateStringId("SI_FOXUC_DEBUG_WARNING", "Отладочный режим может засорять чат технической информацией.")

-- Toggle mode
ZO_CreateStringId("SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM", "Управляемый переключатель вида")
ZO_CreateStringId("SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM_WARNING", "В этом режиме переход между видами не будет мгновенным, так как аддон плавно анимирует изменение зума, в отличие от стандартного поведения игры.")
ZO_CreateStringId("SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM_TT", "Если включено, клавиша переключения вида будет циклично переключать камеру между сохранённым положением от третьего лица и видом от первого лица.\n\nВ этом режиме переход между видами не будет мгновенным, так как аддон плавно анимирует изменение зума, в отличие от стандартного поведения игры.\n\nЕсли выключено, клавиша будет работать как в игре по умолчанию, а аддон будет только отслеживать момент переключения, не меняя зум.")

-- Zoom distance
ZO_CreateStringId("SI_FOXUC_MAX_ZOOM_DISTANCE", "Максимальная дистанция зума")
ZO_CreateStringId("SI_FOXUC_MAX_ZOOM_DISTANCE_TT", "Ограничивает максимальную дистанцию камеры в режиме от третьего лица. Это ограничение действует при любом способе изменения зума (колесико мыши, клавиши, переходы аддона).")

-- Zoom step
ZO_CreateStringId("SI_FOXUC_ZOOM_STEP", "Шаг масштабирования")
ZO_CreateStringId("SI_FOXUC_ZOOM_STEP_TT", "Определяет, на сколько изменяется дистанция зума за одно действие (например, один щелчок колесика мыши). Меньшие значения - более точное и плавное управление, большие - быстрое приближение/отдаление.")

-- Zoom smoothing
ZO_CreateStringId("SI_FOXUC_ZOOM_SMOOTHING", "Сглаживание масштабирования")
ZO_CreateStringId("SI_FOXUC_ZOOM_SMOOTHING_TT", "Если включено, камера будет плавно перемещаться к новой дистанции зума. Если выключено, изменение происходит мгновенно.")

-- Zoom speed
ZO_CreateStringId("SI_FOXUC_ZOOM_SPEED", "Скорость масштабирования")
ZO_CreateStringId("SI_FOXUC_ZOOM_SPEED_TT", "Управляет скоростью плавного перехода камеры при включенном сглаживании. Низкие значения - медленный и плавный переход. Высокие - быстрый и отзывчивый.")

-- Field of View
ZO_CreateStringId("SI_FOXUC_FOV_FIRST_PERSON", "Поле зрения (от 1-го лица)")
ZO_CreateStringId("SI_FOXUC_FOV_FIRST_PERSON_TT", "Настраивает поле зрения в режиме от первого лица. Ползунок использует диапазон 70–130, как и в стандартных настройках игры.")
ZO_CreateStringId("SI_FOXUC_FOV_THIRD_PERSON", "Поле зрения (от 3-го лица)")
ZO_CreateStringId("SI_FOXUC_FOV_THIRD_PERSON_TT", "Настраивает поле зрения в режиме от третьего лица. Ползунок использует диапазон 70–130, как и в стандартных настройках игры.")
ZO_CreateStringId("SI_FOXUC_FOV_RESTORE_ORIGINAL", "Восстановить оригинальное FOV")
ZO_CreateStringId("SI_FOXUC_FOV_RESTORE_ORIGINAL_TT", "Восстанавливает исходные значения поля зрения для первого и третьего лица, сохранённые при первом запуске аддона.")
ZO_CreateStringId("SI_FOXUC_FOV_SMOOTHING", "Сглаживание FOV")
ZO_CreateStringId("SI_FOXUC_FOV_SMOOTHING_TT", "Если включено, изменения поля зрения будут применяться плавно, а не мгновенно.")
ZO_CreateStringId("SI_FOXUC_FOV_SMOOTHING_SPEED", "Скорость сглаживания FOV")
ZO_CreateStringId("SI_FOXUC_FOV_SMOOTHING_SPEED_TT", "Определяет, как быстро поле зрения будет переходить к целевому значению. Чем выше значение, тем быстрее переход.")

-- Zoom settings submenu
ZO_CreateStringId("SI_FOXUC_ZOOM_SUBMENU", "Настройки зума")
ZO_CreateStringId("SI_FOXUC_ZOOM_SUBMENU_TT", "Основные параметры зума: максимальная дистанция, шаг, сглаживание и скорость.")

-- Contextual FOV
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_HEADER", "Контекстный FOV")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_ENABLED", "Контекстное поле зрения (FOV)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_ENABLED_TT", "Автоматически изменяет поле зрения в зависимости от ситуации: в бою, на маунте и в помещениях.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_IGNORE_PVP", "Игнорировать PvP-зоны")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_IGNORE_PVP_TT", "Если включено, контекстное поле зрения не будет действовать в PvP-локациях (Сиродил, поля сражений).")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_COMBAT_FIRST", "FOV в бою (от 1-го лица)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_COMBAT_FIRST_TT", "Целевое поле зрения от первого лица в бою. Использует диапазон 70–130, как и стандартные настройки камеры.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_COMBAT_THIRD", "FOV в бою (от 3-го лица)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_COMBAT_THIRD_TT", "Целевое поле зрения от третьего лица в бою. Использует диапазон 70–130, как и стандартные настройки камеры.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_MOUNTED_FIRST", "FOV на маунте (от 1-го лица)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_MOUNTED_FIRST_TT", "Целевое поле зрения от первого лица на маунте. Использует диапазон 70–130, как и стандартные настройки камеры.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_MOUNTED_THIRD", "FOV на маунте (от 3-го лица)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_MOUNTED_THIRD_TT", "Целевое поле зрения от третьего лица на маунте. Использует диапазон 70–130, как и стандартные настройки камеры.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_INTERIOR_FIRST", "FOV в помещениях (от 1-го лица)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_INTERIOR_FIRST_TT", "Целевое поле зрения от первого лица в помещениях (дома/подземелья). Использует диапазон 70–130, как и стандартные настройки камеры.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_INTERIOR_THIRD", "FOV в помещениях (от 3-го лица)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_INTERIOR_THIRD_TT", "Целевое поле зрения от третьего лица в помещениях (дома/подземелья). Использует диапазон 70–130, как и стандартные настройки камеры.")
-- Contextual FOV headers
ZO_CreateStringId("SI_FOXUC_HEADER_COMBAT_FOV", "FOV в бою")
ZO_CreateStringId("SI_FOXUC_HEADER_MOUNTED_FOV", "FOV на маунте")
ZO_CreateStringId("SI_FOXUC_HEADER_INTERIOR_FOV", "FOV в помещениях")

-- Context speed submenu
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_SUBMENU", "Скорость зума в разных ситуациях")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_SUBMENU_TT", "Настройте скорость зума для боя, скрытности и верхом на маунте.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_SEPARATE_IN_OUT", "Разные скорости приближения и отдаления")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_SEPARATE_IN_OUT_TT", "Если включено, вы сможете настроить отдельную скорость для приближения и отдаления в каждом состоянии (бой, скрытность, маунт). Если выключено, для обоих направлений будет использоваться один общий ползунок.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT", "Скорость зума в бою")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_TT", "Множитель скорости зума, когда вы в бою. Значения меньше 1 замедляют, больше 1 - ускоряют.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH", "Скорость зума в скрытности")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_TT", "Множитель скорости зума, когда вы в режиме скрытности.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED", "Скорость зума на маунте")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_TT", "Множитель скорости зума, когда вы верхом на маунте.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_IN", "Скорость зума в бою (приближение)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_IN_TT", "Множитель скорости зума при приближении в бою.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_OUT", "Скорость зума в бою (отдаление)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_OUT_TT", "Множитель скорости зума при отдалении в бою.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_IN", "Скорость зума в скрытности (приближение)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_IN_TT", "Множитель скорости зума при приближении в скрытности.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_OUT", "Скорость зума в скрытности (отдаление)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_OUT_TT", "Множитель скорости зума при отдалении в скрытности.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_IN", "Скорость зума на маунте (приближение)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_IN_TT", "Множитель скорости зума при приближении на маунте.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_OUT", "Скорость зума на маунте (отдаление)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_OUT_TT", "Множитель скорости зума при отдалении на маунте.")
-- Context Speed headers
ZO_CreateStringId("SI_FOXUC_HEADER_COMBAT", "Бой")
ZO_CreateStringId("SI_FOXUC_HEADER_STEALTH", "Скрытность")
ZO_CreateStringId("SI_FOXUC_HEADER_MOUNTED", "Маунт")
ZO_CreateStringId("SI_FOXUC_HEADER_SPRINT", "Спринт")

-- Zoom Settings Guide
ZO_CreateStringId("SI_FOXUC_ZOOM_GUIDE_SUBMENU", "Гайд: Справка по настройкам зума")
ZO_CreateStringId("SI_FOXUC_ZOOM_GUIDE_SUBMENU_TT", "Подробное описание всех параметров зума в этом разделе.")
ZO_CreateStringId("SI_FOXUC_ZOOM_GUIDE_TEXT", "|cFFFFCCМаксимальная дистанция:|r Устанавливает верхнюю границу для зума в третьем лице. Все попытки отдалить камеру дальше этого значения будут ограничены.\n\n|cFFFFCCШаг масштабирования:|r Определяет, на сколько изменяется дистанция за одно действие (например, щелчок колесика). Этот шаг используется как для мгновенного, так и для плавного зума.\n\n|cFFFFCCСглаживание:|r Переключает режим между мгновенным изменением и плавным переходом. При включении камера плавно движется к новой дистанции, а не скачёт.\n\n|cFFFFCCСкорость:|r Управляет быстротой плавного перехода. Высокие значения - быстрая смена, низкие - медленная.\n\n|cFFFFCCУправляемый переключатель:|r При включении клавиша вида будет использовать систему зума аддона для переключения между сохранённой дистанцией и видом от первого лица, заменяя стандартное поведение игры.")

-- Context Speed Guide
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_GUIDE_SUBMENU", "Гайд: Справка по контекстной скорости")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_GUIDE_SUBMENU_TT", "Подробное описание всех параметров контекстной скорости зума.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_GUIDE_TEXT", "|cFFFFCCБазовая скорость:|r Глобальный множитель, который определяет скорость зума по умолчанию.\n\n|cFFFFCCРаздельная скорость In/Out:|r Если включено, вы сможете задать разные множители для приближения и отдаления. Если выключено, один ползунок управляет обоими направлениями сразу.\n\n|cFFFFCCКонтекстные множители:|r Дополнительные коэффициенты для боя, скрытности и верховой езды. Активен только один контекст одновременно. Приоритет: |cFFFFCCМаунт|r > |cFFFFCCБой|r > |cFFFFCCСкрытность|r.\n\n|cFFFFCCОбщее влияние:|r Эти множители применяются как к шагу зума, так и к скорости плавного перехода. Они напрямую определяют, как быстро камера приближается или отдаляется в каждом из состояний.")

-- Context Sensitivity submenu
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_SUBMENU", "Контекстная чувствительность")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_SUBMENU_TT", "Настройте чувствительность вращения камеры (мышью) для боя, маунта и спринта.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_ENABLED", "Включить контекстную чувствительность")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_ENABLED_TT", "Включает или отключает автоматическое изменение чувствительности камеры в зависимости от состояния персонажа. Когда отключено, эта функция не оказывает влияния.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_COMBAT", "Чувствительность в бою")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_COMBAT_TT", "Множитель чувствительности мыши для вращения камеры в бою. Значения меньше 1 замедляют, больше 1 - ускоряют.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_MOUNTED", "Чувствительность на маунте")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_MOUNTED_TT", "Множитель чувствительности мыши для вращения камеры, когда вы верхом на маунте.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_SPRINT", "Чувствительность в спринте")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_SPRINT_TT", "Множитель чувствительности мыши для вращения камеры во время спринта.")

-- Context Sensitivity Guide
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_SUBMENU", "Гайд: Справка по контекстной чувствительности")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_SUBMENU_TT", "Подробное описание параметров контекстной чувствительности камеры.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_TEXT", "|cFFFFCCЧто это:|r Контекстная чувствительность изменяет скорость вращения камеры (движением мыши) в зависимости от состояния персонажа.\n\n|cFFFFCCМножители:|r Каждое состояние (бой, маунт, спринт) имеет свой множитель. Значение 1.0 - стандартная чувствительность. Меньше 1.0 - медленнее. Больше 1.0 - быстрее.\n\n|cFFFFCCПриоритет:|r Если активно несколько состояний одновременно, применяется следующий приоритет: |cFFFFCCМаунт|r > |cFFFFCCБой|r > |cFFFFCCСпринт|r.\n\n|cFFFFCCПрименение:|r Множители влияют на скорость вращения камеры при движении мыши влево, вправо, вверх и вниз.")

-- Camera Offset submenu
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SUBMENU", "Смещение камеры")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SUBMENU_TT", "Динамически изменяйте положение камеры с помощью горячих клавиш. Сохраняйте и загружайте пресеты позиций.")

-- Camera Offset settings
ZO_CreateStringId("SI_FOXUC_HEADER_SMOOTHING", "Сглаживание")
ZO_CreateStringId("SI_FOXUC_HEADER_INDICATOR", "Индикатор")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_ENABLED", "Показывать UI индикатор")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_ENABLED_TT", "Отображать текущие значения смещения камеры на экране при настройке позиции.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_DELAY", "Задержка скрытия индикатора")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_DELAY_TT", "Как долго отображать индикатор смещения после последней настройки (в секундах).")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_RESTORE_ORIGINAL", "Восстановить оригинальные настройки")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_RESTORE_ORIGINAL_TT", "Сбросить позицию камеры на оригинальные значения, сохраненные при первой активации модуля.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL", "Обновить оригинальные настройки")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_TT", "Сохранить текущую позицию камеры как новые 'оригинальные' настройки. Это перезапишет ранее сохраненные значения.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_WARNING", "|cFFA500Внимание:|r это действие перезапишет оригинальные настройки камеры.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_WARNING_CONFIRM", "Это перезапишет оригинальные настройки камеры. Продолжить?")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_CURRENT_VALUES", "Текущее смещение")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_ORIGINAL_VALUES", "Сохраненные оригинальные")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_TEXT", "Смещение камеры: X: %+.2f  Y: %+.2f  -  Зум: %.1f")

-- Shoulder Swap
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_HEADER", "Смена плеча")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_SMART_MODE", "Умный режим")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_SMART_MODE_TT", "Динамически зеркально отражает положение камеры по оси X, адаптируясь под ваши изменения в реальном времени, вместо использования фиксированных значений.")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_LEFT_VALUE", "Смещение для левого плеча")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_LEFT_VALUE_TT", "Позиция камеры по оси X для вида с левого плеча.")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_RIGHT_VALUE", "Смещение для правого плеча")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_RIGHT_VALUE_TT", "Позиция камеры по оси X для вида с правого плеча.")

-- Camera Offset keybindings
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_LEFT", "Камера влево")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_RIGHT", "Камера вправо")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_UP", "Камера вверх")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_DOWN", "Камера вниз")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_RESET", "Сбросить в центр")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_SHOULDER_SWAP", "Смена плеча")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_SAVE_PRESET_1", "Сохранить пресет 1")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_SAVE_PRESET_2", "Сохранить пресет 2")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_SAVE_PRESET_3", "Сохранить пресет 3")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_LOAD_PRESET_1", "Загрузить пресет 1")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_LOAD_PRESET_2", "Загрузить пресет 2")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_LOAD_PRESET_3", "Загрузить пресет 3")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_RESTORE_ORIGINAL", "Восстановить оригинальные")

-- Camera Offset Guide
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_GUIDE_SUBMENU", "Гайд: Справка по смещению камеры")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_GUIDE_SUBMENU_TT", "Подробное описание управления смещением камеры и его функций.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_GUIDE_TEXT", "|cFFFFCCЧто это:|r Смещение камеры позволяет настраивать горизонтальное (X) и вертикальное (Y) положение камеры в реальном времени через горячие клавиши.\n\n|cFFFFCCГорячие клавиши:|r Настройте привязки в Управление > Привязки аддонов. Используйте Влево/Вправо/Вверх/Вниз для перемещения камеры. Одиночное нажатие - малый шаг, удержание - непрерывное движение.\n\n|cFFFFCCПресеты:|r Сохраните до 3 пресетов позиции камеры (включая уровень зума). Быстро восстанавливайте любимые положения камеры одной клавишей.\n\n|cFFFFCCОригинальные настройки:|r Ваши настройки камеры автоматически сохраняются при первой активации модуля. Используйте 'Восстановить оригинальные' для отмены всех изменений.\n\n|cFFFFCCОграничения:|r Диапазон смещения ограничен стандартными настройками камеры ESO. Доступный диапазон зависит от текущей дистанции зума.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SMOOTHING", "Включить сглаживание")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SMOOTHING_TT", "При включении камера будет плавно перемещаться к новой позиции смещения (при загрузке пресета или восстановлении).")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SMOOTHING_SPEED", "Скорость сглаживания")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SMOOTHING_SPEED_TT", "Определяет скорость плавного перехода камеры к новой позиции.")

-- Основной блок камеры
ZO_CreateStringId("SI_FOXUC_CAMERA_SECTION_DESC", "Расширяет пределы зума и сглаживания, позволяет смещать камеру по горизонтали и вертикали, сохранять несколько пресетов положения и дистанции, автоматически подстраивать FOV и скорость/чувствительность камеры под контекст (бой, маунт, скрытность), а также включает более иммерсивные режимы диалоговой камеры.")

-- First-Person Auto Mode
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_SUBMENU", "Автопереключение в вид от 1-го лица")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_SUBMENU_TT", "Автоматически переключает вид между первым и третьим лицом в зависимости от ситуации: в помещениях, в бою, на маунте.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_ENABLED", "Включить автопереключение")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_ENABLED_TT", "При включении аддон будет автоматически переключать камеру в режим от первого лица и обратно в третье лицо в зависимости от условий ниже.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_INTERIORS", "В помещениях")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_INTERIORS_TT", "Автоматически переключаться в вид от первого лица, когда вы находитесь в доме или в инстансе подземелья.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_COMBAT", "В бою")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_TT", "Автоматически переключаться в вид от первого лица во время боя и возвращаться к виду от третьего лица после его окончания.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_MOUNT", "На маунте")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_MOUNT_TT", "Автоматически переключаться в вид от первого лица, когда вы верхом на маунте, и возвращаться к виду от третьего лица после спешивания.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_IGNORE_PVP", "Игнорировать PvP-зоны")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_IGNORE_PVP_TT", "Если включено, автопереключение не будет работать в PvP-локациях (Сиродил, поля сражений).")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTIONS_ENABLED", "Включить иммерсивный режим")
ZO_CreateStringId("SI_FOXUC_IMMERSION_MODE_HEADER", "|cE5FBC8Иммерсивный режим|r")
ZO_CreateStringId("SI_FOXUC_IMMERSION_MODE_DESC", "Сохраняет положение камеры во время диалогов и взаимодействий.\nПредотвращает резкие смены ракурса, вызванные как игрой, так и аддоном.")
ZO_CreateStringId("SI_FOXUC_IMMERSION_MODE_STATUS_ON", "|c00FF00АКТИВЕН|r")
ZO_CreateStringId("SI_FOXUC_IMMERSION_MODE_STATUS_OFF", "|cFF6666ОТКЛЮЧЁН|r")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTIONS_ENABLED_TT", "Предотвращает резкие смены камеры как со стороны аддона, так и со стороны игровой диалоговой камеры во время взаимодействий с миром.\n\n|cFFFFCCКак это работает:|r\n- |cFFFFFFСвободная камера диалога:|r Для большинства разговоров с NPC, чтения книг и простых взаимодействий игровая диалоговая камера отключается - вид остаётся таким, каким он был в момент начала диалога. Сервисные интерфейсы (банк, гильдия, торговый дом, лавки в домах, крафт-станции, wayshrine, стойло маунтов и т.п.) сохраняют стандартное поведение камеры.\n- |cFFFFFFЗаморозка логики аддона:|r Во время любого взаимодействия аддон временно «замораживает» свои функции, управляющие камерой. Текущий вид и настройки камеры сохраняются до конца взаимодействия, а затем аккуратно восстанавливаются.\n\n|cFFFFCCВлияние на функции FOX Ultimate Camera:|r\n- |cFFFFFFАвтопереключение в 1-е лицо:|r Временно отключается. Камера не будет переключаться, пока вы не закончите взаимодействие.\n- |cFFFFFFКонтекстный FOV:|r Если был активен контекст (например, бой), FOV сначала возвращается к базовому значению и не меняется во время взаимодействия. После завершения взаимодействия FOV плавно возвращается к контекстному значению.\n- |cFFFFFFКонтекстная скорость/чувствительность:|r Временно отключаются. Камера использует базовые значения скорости и чувствительности из настроек. После взаимодействия нужные множители применяются снова.")
-- Interaction Camera Exceptions
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTIONS_SUBMENU", "Исключения для диалоговой камеры")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTIONS_SUBMENU_TT", "Выберите, для каких типов взаимодействий следует использовать стандартную игровую камеру вместо режима 'Свободная камера диалога'.")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ENTRY_TT", "Если включено, для этого типа взаимодействия будет использоваться стандартная камера игры (режим 'Свободная камера диалога' не применяется). Если выключено, аддон попытается сохранить ваш текущий вид.")
ZO_CreateStringId("SI_FOXUC_IMMERSION_PREVIEW_GUIDE_SUBMENU", "Гайд: Иммерсивный режим и предпросмотр")
ZO_CreateStringId("SI_FOXUC_IMMERSION_PREVIEW_GUIDE_SUBMENU_TT", "Объясняет, как иммерсивный режим взаимодействует с предпросмотром предметов и почему некоторые сервисы исключены по умолчанию.")
ZO_CreateStringId("SI_FOXUC_IMMERSION_PREVIEW_GUIDE_TEXT", "|cFFFFCCСвободная камера диалога vs. сервисы:|r Иммерсивный режим в первую очередь рассчитан на диалоги с NPC, чтение книг и простые взаимодействия, где важно сохранить текущий ракурс.\n\nСервисные интерфейсы - торговцы, гильдейские магазины, банки, оружейные, конюшни и подобные окна - зависят от стандартной игровой камеры и сцены для корректного показа предпросмотра и 3D‑моделей. Если принудительно включить там 'Свободную камеру диалога', часть предпросмотра может работать некорректно или не работать вовсе.\n\n|cFFFFCCИсключения для диалоговой камеры:|r В списке выше вы можете выбрать, какие типы взаимодействий всегда используют стандартную камеру. |cFFFFFFРекомендуется:|r оставить включёнными все торговые, банковские, жилищные, оружейные, конюшни и системы древностей, чтобы предпросмотр продолжал работать как в ванильной игре.\n\nЕсли отключить исключения для этих сервисов, вы получите более агрессивный стиль камеры, но можете частично лишиться привычного предпросмотра.")

-- Immersive interaction types (service interfaces)
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_CRAFT", "Станции крафта")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_DYE_STATION", "Станция окрашивания")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_RETRAIT", "Трансмутация")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ARMORY", "Оружейная")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ATTRIBUTE_RESPEC", "Алтарь перераспределения характеристик")

ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_LOCKPICK", "Взлом замков")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_SIEGE", "Осадные орудия")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_FURNITURE", "Мебель и объекты в жилье")

ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_BANK", "Банк")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_GUILD_BANK", "Банк гильдии")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_HOUSE_BANK", "Банк в доме")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_STORE", "Торговцы / Магазины")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_TRADING_HOUSE", "Магазин гильдии / Торговый дом")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_FENCE", "Скупщик краденого")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_HOUSE_STORE", "Торговцы в доме")

ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_AVA_HOOK_POINT", "Строения / Осадные крюки (АВА)")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_WAYSHRINE", "Дорогие святыни")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_KEEP_GUILD_CLAIM", "Захват крепости для гильдии")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_KEEP_GUILD_RELEASE", "Передача крепости от гильдии")

ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_STABLE", "Конюшня")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_MAIL", "Почтовый ящик")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ANTIQUITY_DIG_SPOT", "Место раскопок древностей")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ANTIQUITY_SCRYING", "Гадание на древности")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_RESPECT_MANUAL", "Не отменять ручное переключение")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_RESPECT_MANUAL_TT", "После того как вы вручную переключили вид камеры, автопереключение на время приостановит свою работу, чтобы не отменять ваш выбор.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_ENTER_DELAY", "Задержка входа (сек)")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_ENTER_DELAY_TT", "Как долго условие должно оставаться активным, прежде чем камера переключится в вид от первого лица. Помогает избежать дёргания при коротких заходах в бой или на маунта.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_EXIT_DELAY", "Задержка выхода (сек)")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_EXIT_DELAY_TT", "Как долго условия должны оставаться неактивными, прежде чем камера вернётся к виду от третьего лица.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_MANUAL_TIMEOUT", "Таймаут ручного режима (сек)")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_MANUAL_TIMEOUT_TT", "После ручного переключения вида автопереключение будет отключено на указанное время. Установите 0, чтобы отключить эту задержку.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_CHAIN_TIMEOUT", "Окно после боя (сек)")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_CHAIN_TIMEOUT_TT", "После окончания боя аддон ещё будет считать вас 'в бою' в течение этого времени. Это предотвращает частое переключение вида, если бои идут подряд.")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_ENABLED", "Автоматически убирать оружие")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_ENABLED_TT", "Автоматически убирает оружие по окончании боя с учётом заданной задержки.")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_IGNORE_PVP", "Игнорировать PvP-зоны")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_IGNORE_PVP_TT", "Если включено, автоубирание оружия не будет работать в PvP-зонах (Сиродил, поля сражений).\n\n|cFFA500Включено по умолчанию|r, чтобы предотвратить случайное убирание оружия в PvP.")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_ON_EMOTE", "Убирать оружие при эмоциях")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_ON_EMOTE_TT", "Автоматически убирать оружие при использовании эмоции.\n\n|cFFA500Включено по умолчанию|r.")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_DELAY", "Задержка перед убиранием (сек)")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_DELAY_TT", "Как долго ждать после окончания боя, прежде чем автоматически убрать оружие.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_SUBMENU", "Гайд: Справка по автопереключению")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_SUBMENU_TT", "Подробное описание всех настроек автопереключения.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_TEXT", "|cFFFFCCЧто это:|r Автопереключение автоматически меняет вид камеры между первым и третьим лицом в зависимости от контекста (помещения, бой, маунт).\n\n|cFFFFCCУсловия:|r Вы можете включить любые комбинации условий. Если одновременно активно несколько, используется следующий приоритет: |cFFFFCCМаунт|r > |cFFFFCCБой|r > |cFFFFCCПомещения|r.\n\n|cFFFFCCЗадержки:|r Задержки входа и выхода помогают избежать дёргания, когда вы лишь на мгновение входите в бой или садитесь на маунта. Условие должно оставаться активным/неактивным всю длительность задержки, прежде чем вид изменится.\n\n|cFFFFCCРучное управление:|r Когда вы вручную переключаете вид, автопереключение может на время приостановить свою работу, чтобы не отменять ваш выбор.")
