#Requires AutoHotkey v2.0
if !A_IsAdmin {
    try Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

global CURRENT_LANG := GetSystemLanguage()
global CURRENT_THEME := GetSystemTheme()
global WORKSPACE_COUNT := 4
global SHOW_FEEDBACK := true
global ANIMATION_MS := 180
global MOUSE_SCREEN_WINDOWS := true
global KnownWindows := Map()
global SettingsGui := 0

global CurrentWorkspace := Map()
global WindowWorkspace := Map()
global HiddenByScript := Map()
global WorkspaceOverlays := Map()
global Switching := false

; --- DİL SÖZLÜĞÜ (i18n) ---
global LANG := Map(
    "TR", Map(
        "tray_settings", "Ayarlar",
		"tray_about", "Hakkında",
		"about_description", "Her monitör için bağımsız çalışma alanları.",
		"about_built", "AutoHotkey v2 ile geliştirilmiştir.",
		"about_github","GitHub",
        "tray_open_ahk", "Program Konumunu Aç",
        "tray_reset", "Tüm Pencereleri Göster ve Sıfırla",
        "tray_help", "Kullanım Rehberi",
        "tray_reload", "Yeniden Başlat",
        "tray_exit", "Çıkış (Gizli Pencereleri Aç)",
        "tray_tip", "Bağımsız Monitör Çalışma Alanları",
        "tray_screens", "Çalışma Alanları",
        "tray_screen", "Ekran",
        "tray_workspace", "Çalışma Alanı",
        
        "set_title", "Bağımsız Monitör Çalışma Alanları - Ayarlar",
        "set_header", "Uygulama Ayarları",
        "set_sub", "Çalışma alanı ve bildirim tercihlerini özelleştirin:",
        "set_ws_count", "Çalışma Alanı Sayısı",
        "set_ws_count_desc", "Monitör başına düşen alan sayısı (1-5)",
        "set_mouse_screen", "Pencereler Farenin Olduğu Ekranda Açılsın",
        "set_mouse_screen_desc", "Yeni pencereleri fare imlecinin bulunduğu ekrana taşı ve ortala",
        "set_startup", "Başlangıçta Açılsın",
        "set_startup_desc", "Windows açıldığında uygulama otomatik olarak başlasın",
        "set_feedback", "Görsel Ekran Bildirimi",
        "set_feedback_desc", "Geçişlerde ekranda bilgi kartı göster",
        "set_feedback_active", "Aktif",
        "set_anim", "Animasyon Süresi (ms)",
        "set_anim_desc", "Overlay geçiş hızı (Milisaniye)",
        "set_lang", "Uygulama Dili / Language",
        "set_lang_desc", "Arayüz ve bildirim dilini seçin",
        "set_theme", "Uygulama Teması",
        "set_theme_desc", "Koyu veya açık arayüz temasını seçin",
        "set_theme_dark", "Koyu (Dark)",
        "set_theme_light", "Açık (Light)",
        "set_info_title", "BİLGİ:",
        "set_info_desc", "Değişiklikler Kaydet butonuna tıkladığınız anda aktif olacaktır.",
        "btn_save", "Kaydet",
        "btn_cancel", "İptal",
        "msg_saved", "AYARLAR KAYDEDİLDİ",

        "help_title", "Bağımsız Monitör Çalışma Alanları - Kullanım Rehberi",
        "help_header", "Bağımsız Monitör Çalışma Alanları",
        "help_sub", "Kontrol etmek istediğiniz monitörün üzerine fareyide getirin ve aşağıdaki kısayolları kullanın:",
        "help_sec1", "Çalışma Alanı Geçişi",
        "help_sec1_desc", "Önceki / Sonraki alana geç",
        "help_sec2", "Hızlı Çalışma Alanı Geçişi",
        "help_sec2_desc", "Görev çubuğunda fare tekerleği",
        "help_sec2_btn1", "Görev Çubuğu",
        "help_sec2_btn2", "Tekerlek Yukarı / Aşağı",
        "help_sec3", "Aktif Alan Pencere İşlemleri",
        "help_sec3_desc", "Sadece aktif ekrandaki pencereler",
        "help_sec3_sub", "(Fare tıklaması & Hover destekli)",
        "help_sec4", "Pencereyi Taşı",
        "help_sec4_desc", "En üstteki pencereyi hedefe gönder",
        "help_sec5", "Doğrudan Alana Geç",
        "help_sec5_desc", "Belirtilen numaralı alana geç",
        "help_sec6", "Sıfırla ve Göster",
        "help_sec6_desc", "Gizli tüm pencereleri görünür yap",
        "help_tip_title", "ÖNEMLİ İPUCU:",
        "help_tip_desc1", "Her monitör bağımsızdır. Komutlar farenizin durduğu ekrandaki pencereleri etkiler.",
        "help_tip_desc2", "Tepsi simgesinden (Tray Menu) istediğiniz zaman ayarlara ulaşabilirsiniz.",
        "btn_understand", "Anladım",

        "ov_ready", "HAZIR",
        "ov_reset", "SIFIRLANDI",
        "ov_first", "İLK ALAN",
        "ov_last", "SON ALAN",
        "ov_moved", ". ALANA TAŞINDI",
        "ov_monitor", "EKRAN ",
        "ov_default_prefix", "ÇALIŞMA ALANI",
        "no_windows_msg", "Bu çalışma alanında açık pencere yok",
		
		"installation_ask_to_install_title", "WorkspaceSwitcher Kurulum",
		"installation_ask_to_install", "Program kurulsun mu? Program Files altına kurulacak ve başlangıçta açılacak. Devam Etmek İstiyor musunuz?",
		"installation_install_success", "Kurulum başarıyla tamamlandı! Program yeni konumundan başlatılacak.",
		"installation_install_success_title", "Başarılı",
		"installation_install_error", "Kurulum sırasında bir hata oluştu: ",
		"installation_install_error_title", "Hata",
		
		"tray_uninstall", "Programı Kaldır",
        "uninstall_ask", "Programı kaldırmak istediğinize emin misiniz? Başlangıç kısayolu ve tüm kurulum dosyaları silinecektir.",
        "uninstall_ask_title", "Kaldırma İşlemi",
        "uninstall_success", "Program başarıyla kaldırıldı.",
        "uninstall_success_title", "Kaldırıldı",
		
		"close", "Kapat"
		
    ),
    "EN", Map(
        "tray_settings", "Settings",
		"tray_about", "About",
		"about_description", "Independent workspaces for each monitor.",
		"about_built", "Built with AutoHotkey v2.",
		"about_github","GitHub",
        "tray_open_ahk", "Open Program Location",
        "tray_reset", "Show All Windows & Reset",
        "tray_help", "User Guide",
        "tray_reload", "Restart",
        "tray_exit", "Exit (Unhide Windows)",
        "tray_tip", "Independent Monitor Workspaces",
        "tray_screens", "Workspaces",
        "tray_screen", "Screen",
        "tray_workspace", "Workspace",
        
        "set_title", "Independent Monitor Workspaces - Settings",
        "set_header", "Application Settings",
        "set_sub", "Customize workspace and notification preferences:",
        "set_ws_count", "Workspace Count",
        "set_ws_count_desc", "Number of workspaces per monitor (1-5)",
        "set_mouse_screen", "Open Windows on the Mouse Screen",
        "set_mouse_screen_desc", "Move new windows to the screen under the mouse and center them",
        "set_startup", "Start with Windows",
        "set_startup_desc", "Automatically start application when Windows boots",
        "set_feedback", "Visual Screen Notification",
        "set_feedback_desc", "Show overlay card on transitions",
        "set_feedback_active", "Enabled",
        "set_anim", "Animation Duration (ms)",
        "set_anim_desc", "Overlay animation speed (Milliseconds)",
        "set_lang", "Application Language",
        "set_lang_desc", "Select interface and overlay language",
        "set_theme", "Application Theme",
        "set_theme_desc", "Select dark or light interface theme",
        "set_theme_dark", "Dark",
        "set_theme_light", "Light",
        "set_info_title", "INFO:",
        "set_info_desc", "Changes will take effect as soon as you click Save.",
        "btn_save", "Save",
        "btn_cancel", "Cancel",
        "msg_saved", "SETTINGS SAVED",

        "help_title", "Independent Monitor Workspaces - User Guide",
        "help_header", "Independent Monitor Workspaces",
        "help_sub", "Move mouse over the target monitor and use shortcuts below:",
        "help_sec1", "Workspace Switch",
        "help_sec1_desc", "Switch to Previous / Next area",
        "help_sec2", "Fast Workspace Switch",
        "help_sec2_desc", "Mouse wheel on taskbar",
        "help_sec2_btn1", "Taskbar",
        "help_sec2_btn2", "Wheel Up / Down",
        "help_sec3", "Active Workspace Windows",
        "help_sec3_desc", "Windows on active monitor only",
        "help_sec3_sub", "(Supports mouse click & hover)",
        "help_sec4", "Move Window",
        "help_sec4_desc", "Send top window to target area",
        "help_sec5", "Direct Switch",
        "help_sec5_desc", "Jump directly to specified area",
        "help_sec6", "Reset & Reveal",
        "help_sec6_desc", "Make all hidden windows visible",
        "help_tip_title", "IMPORTANT TIP:",
        "help_tip_desc1", "Monitors are independent. Commands affect the screen under cursor.",
        "help_tip_desc2", "Access settings anytime via the Tray Menu icon.",
        "btn_understand", "Got It",

        "ov_ready", "READY",
        "ov_reset", "RESET COMPLETE",
        "ov_first", "FIRST WORKSPACE",
        "ov_last", "LAST WORKSPACE",
        "ov_moved", " MOVED TO WORKSPACE",
        "ov_monitor", "MONITOR ",
        "ov_default_prefix", "WORKSPACE",
        "no_windows_msg", "No open windows in this workspace",
		
		"installation_ask_to_install_title", "WorkspaceSwitcher Installation",
		"installation_ask_to_install", "The program will be installed in the Program Files folder and will automatically start with Windows. Do you want to continue?",
		"installation_install_success", "Installation completed successfully! The program will now start from its new location.",
		"installation_install_success_title", "Success",
		"installation_install_error", "An error occurred during installation: ",
		"installation_install_error_title", "Error",
		
		"tray_uninstall", "Uninstall Program",
        "uninstall_ask", "Are you sure you want to uninstall the program? Startup shortcut and all files will be removed.",
        "uninstall_ask_title", "Uninstall",
        "uninstall_success", "Program uninstalled successfully.",
        "uninstall_success_title", "Success",
		
		"close", "Close"
    )
)

T(key) {
	global CURRENT_LANG, LANG
	if LANG.Has(CURRENT_LANG) && LANG[CURRENT_LANG].Has(key)
		return LANG[CURRENT_LANG][key]
	return LANG["TR"].Has(key) ? LANG["TR"][key] : key
}


; Kurulum ve Başlangıç Kontrolü
CheckAndInstall()



CheckAndInstall() {
	; Kaynak kod (.ahk) doğrudan çalıştırılıyorsa kurulum yapma.
    ; Kurulum yalnızca derlenmiş EXE üzerinden gerçekleştirilir.
    if !A_IsCompiled
        return
		
    targetDir := A_ProgramFiles "\WorkspaceSwitcher"
    targetExe := targetDir "\WorkspaceSwitcher.exe"
    startupDir := A_Startup
    shortcutPath := startupDir "\WorkspaceSwitcher.exe.lnk"

    ; Eğer program zaten Program Files altında çalışmıyorsa kurulumu sorgula
    if (A_ScriptFullPath != targetExe) {
        result := MsgBox(T("installation_ask_to_install"), T("installation_ask_to_install_title"), "YesNo")
        
        if (result = "Yes") {
            try {
                ; Klasör yoksa oluştur
                if !DirExist(targetDir)
                    DirCreate(targetDir)
                
                ; Çalıştırılabilir dosyayı ve varsa gerekli kaynakları kopyala
                FileCopy(A_ScriptFullPath, targetExe, 1)
                
                ; Başlangıç klasörüne kısayol oluştur
                FileCreateShortcut(targetExe, shortcutPath)
                
                MsgBox(T("installation_install_success"), T("installation_install_success_title"), "OK")
                
                ; Yeni kurulan dosyayı başlat ve mevcut olanı kapat
                Run(targetExe)
                ExitApp()
            } catch as err {
                MsgBox(T("installation_install_error") err.Message, T("installation_install_error_title"), "IconX")
            }
        }
    }
}


UninstallProgram(*) {
    result := MsgBox(T("uninstall_ask"), T("uninstall_ask_title"), "YesNo Icon!")
    if (result != "Yes")
        return

    targetDir := A_ProgramFiles "\WorkspaceSwitcher"
    startupShortcut := A_Startup "\WorkspaceSwitcher.exe.lnk"

    try {
        ; 1. Başlangıç kısayolunu sil
        if FileExist(startupShortcut)
            FileDelete(startupShortcut)

        ; 2. Geçici bir batch dosyası oluşturarak Program Files klasörünü ve exe'yi sil
        batchPath := A_Temp "\uninstall_ws.bat"
        batContent := '@echo off`n'
        batContent .= 'timeout /t 2 /nobreak > nul`n'
        batContent .= 'rmdir /s /q "' targetDir '"`n'
        batContent .= 'del "%~f0"`n'
        
        FileConst := FileOpen(batchPath, "w", "UTF-8")
        FileConst.Write(batContent)
        FileConst.Close()

        Run(batchPath, , "Hide")
        
        MsgBox(T("uninstall_success"), T("uninstall_success_title"), "OK")
        ExitApp()
    } catch as err {
        MsgBox("Kaldırma sırasında hata oluştu: " err.Message, "Hata", "IconX")
    }
}


#SingleInstance Force
Persistent

; ==============================================================================
; AHK2EXE DERLEYİCİ DİREKTİFLERİ (İkonları Exe'ye Gömeç)
; ==============================================================================
;@Ahk2Exe-AddResource icon\settings.ico,1001
;@Ahk2Exe-AddResource icon\folder.ico,1002
;@Ahk2Exe-AddResource icon\reset.ico,1003
;@Ahk2Exe-AddResource icon\help.ico,1004
;@Ahk2Exe-AddResource icon\reload.ico,1005
;@Ahk2Exe-AddResource icon\exit.ico,1006
;@Ahk2Exe-AddResource icon\active-workspace.ico,1007
;@Ahk2Exe-AddResource icon\color-settings.ico,1008
;@Ahk2Exe-AddResource icon\direct-workspace-switch.ico,1009
;@Ahk2Exe-AddResource icon\duration.ico,1010
;@Ahk2Exe-AddResource icon\fast-workspace-switch.ico,1011
;@Ahk2Exe-AddResource icon\info.ico,1012
;@Ahk2Exe-AddResource icon\info-lamp.ico,1013
;@Ahk2Exe-AddResource icon\language.ico,1014
;@Ahk2Exe-AddResource icon\move-window.ico,1015
;@Ahk2Exe-AddResource icon\reset-show.ico,1016
;@Ahk2Exe-AddResource icon\screen-notify.ico,1017
;@Ahk2Exe-AddResource icon\theme.ico,1018
;@Ahk2Exe-AddResource icon\workspaces.ico,1019
;@Ahk2Exe-AddResource icon\workspace-switch.ico,1020
;@Ahk2Exe-AddResource icon\workspaces1.ico,1021
;@Ahk2Exe-AddResource icon\windowstomouse.ico,1022
;@Ahk2Exe-AddResource icon\uninstall.ico,1023
;@Ahk2Exe-AddResource icon\runatstartup.ico,1024
;@Ahk2Exe-AddResource icon\about.ico,1025

APP_VERSION := "1.5.0"

; --- SİSTEM DİLİ VE TEMA ALGILAMA ---
GetSystemLanguage() {
    langID := DllCall("GetUserDefaultUILanguage", "UShort")
    primaryLang := langID & 0x3FF
    return (primaryLang = 0x1F) ? "TR" : "EN"
}

GetSystemTheme() {
    regPath := "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    try {
        lightTheme := RegRead(regPath, "AppsUseLightTheme")
        return (lightTheme = 1) ? "LIGHT" : "DARK"
    } catch {
        return "DARK"
    }
}



; --- TEMA PALETİ DESTEĞİ ---
global THEMES := Map(
    "DARK", Map(
        "bg_main", "0F172A",
        "bg_card", "1E293B",
        "bg_card_selected", "1E3A8A",
        "bg_gui", "1E293B",
        "bg_box", "0F172A",
        "bg_input", "0F172A",
        "bg_key", "334155",
        "text_key", "FFFFFF",
        "border_key", "475569",
        "text_main", "F8FAFC",
        "text_sub", "94A3B8",
        "text_card", "F1F5F9",
        "text_card_selected", "93C5FD",
        "text_info", "93C5FD",
        "border", "334155",
        "accent", "2563EB",
        "accent_hover", "3B82F6",
        "btn_bg", "334155",
        "btn_txt", "E2E8F0"
    ),
    "LIGHT", Map(
        "bg_main", "F1F5F9",
        "bg_card", "FFFFFF",
        "bg_card_selected", "DBEAFE",
        "bg_gui", "FFFFFF",
        "bg_box", "F8FAFC",
        "bg_input", "FFFFFF",
        "bg_key", "E2E8F0",
        "text_key", "0F172A",
        "border_key", "CBD5E1",
        "text_main", "0F172A",
        "text_sub", "475569",
        "text_card", "0F172A",
        "text_card_selected", "1E40AF",
        "text_info", "1E3A8A",
        "border", "CBD5E1",
        "accent", "2563EB",
        "accent_hover", "3B82F6",
        "btn_bg", "E2E8F0",
        "btn_txt", "1E293B"
    )
)

GetTheme() {
    global CURRENT_THEME, THEMES
    return THEMES.Has(CURRENT_THEME) ? THEMES[CURRENT_THEME] : THEMES["DARK"]
}

GetThemeColor(key) {
    theme := GetTheme()
    return theme.Has(key) ? theme[key] : "000000"
}



; --- ÖZEL ALT+TAB DEĞİŞKENLERİ ---
global CustomTabGui := 0
global CustomTabList := []
global CustomTabIndex := 1
global LastTabIndex := 0
global TrayTabMode := false

DetectHiddenWindows true
SetTitleMatchMode 2
SetWinDelay -1

InitializeMonitors()
UpdateTrayMenu()
OnExit(RestoreAllWindows)
OnMessage(0x007E, HandleDisplayChange)
OnMessage(0x0404, HandleTrayIconMessage)

DllCall("SetWinEventHook"
    , "UInt", 0x0003
    , "UInt", 0x0003
    , "Ptr", 0
    , "Ptr", CallbackCreate(OnWindowActivated)
    , "UInt", 0
    , "UInt", 0
    , "UInt", 0)

; Başlangıçta mevcut pencereleri kaydet; bunlar daha sonra taşınmaz.
InitializeKnownWindows()
SetTimer(CheckNewWindows, 200)

Loop 5 {
    workspace := A_Index
    Hotkey("#^" workspace, SwitchToWorkspace.Bind(workspace))
    Hotkey("#^Numpad" workspace, MoveTopWindowToWorkspace.Bind(workspace))
}


Hotkey("#^Left", PreviousWorkspace)
Hotkey("#^Right", NextWorkspace)
Hotkey("#^+Esc", ResetAndRevealAll)

#HotIf IsHoveringTaskbar()
WheelUp::PreviousWorkspace()
WheelDown::NextWorkspace()
#HotIf

IsHoveringTaskbar() {
    MouseGetPos ,, &hwnd
    if !hwnd
        return false
    try class := WinGetClass("ahk_id " hwnd)
    catch
        return false
    return (class = "Shell_TrayWnd" || class = "Shell_SecondaryTrayWnd")
}

; --- FARE VE TIKLAMA DESTEKLİ ALT+TAB ---
global TabCardControls := []
global HoverRegistered := false
global TopWorkspaceHeaderBtns := []
global CustomTabHoverTimerRunning := false

; Fare hareketi takibini program açılışında da aktif et.
OnMessage(0x0200, OnMouseMove)
global HoverRegistered := true

!Tab:: {
    HandleCustomTabNavigation(1)
}

!+Tab:: {
    HandleCustomTabNavigation(-1)
}

HandleCustomTabNavigation(step := 1) {
    global CustomTabGui, CustomTabList, CustomTabIndex, LastTabIndex, HiddenByScript, CurrentWorkspace, WindowWorkspace, HoverRegistered

    if CustomTabGui {
        if (CustomTabList.Length > 0) {
            newIndex := CustomTabIndex + step
            if (newIndex > CustomTabList.Length)
                newIndex := 1
            else if (newIndex < 1)
                newIndex := CustomTabList.Length
                
            UpdateCustomTabSelection(newIndex)
        }
        return
    }

    targetMonitor := GetMonitorUnderMouse()
    activeWS := CurrentWorkspace.Has(targetMonitor) ? CurrentWorkspace[targetMonitor] : 1

    CustomTabList := []
    for hwnd in WinGetList() {
        if HiddenByScript.Has(hwnd) || !IsManageableWindow(hwnd) || !IsVisible(hwnd)
            continue

        if (GetWindowMonitor(hwnd) = targetMonitor) {
            if WindowWorkspace.Has(hwnd) && WindowWorkspace[hwnd].workspace != activeWS
                continue

            try title := WinGetTitle("ahk_id " hwnd)
            catch
                title := ""

            if (title != "")
                CustomTabList.Push({hwnd: hwnd, title: title})
        }
    }

    CustomTabIndex := (CustomTabList.Length > 1) ? (step > 0 ? 2 : CustomTabList.Length) : 1
    LastTabIndex := CustomTabIndex
    ShowCustomTabMenu(targetMonitor)
}

ShowCustomTabMenu(monitor) {
    global CustomTabGui, CustomTabList, CustomTabIndex, LastTabIndex, TabCardControls, WORKSPACE_COUNT, CurrentWorkspace, TopWorkspaceHeaderBtns, CustomTabHoverTimerRunning

    MonitorGetWorkArea(monitor, &left, &top, &right, &bottom)

    if CustomTabGui {
        try CustomTabGui.Destroy()
        CustomTabGui := 0
    }

    CustomTabGui := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
    CustomTabGui.MarginX := 0
    CustomTabGui.MarginY := 0
    CustomTabGui.BackColor := GetThemeColor("bg_main")

    maxCards := 20
    cardsPerRow := 5

    cardWidth := 140
    cardHeight := 100
    spacing := 12
    padding := 18

    totalCount := CustomTabList.Length
    if (totalCount > maxCards) {
        CustomTabList.Length := maxCards
        totalCount := maxCards
    }

    rowCount := (totalCount > 0) ? Ceil(totalCount / cardsPerRow) : 1

    wsBtnW := 90, wsBtnH := 36, wsGap := 8
    wsBarW := (WORKSPACE_COUNT * wsBtnW) + ((WORKSPACE_COUNT - 1) * wsGap) + 16
    wsBarH := wsBtnH + 12
    topOffset := wsBarH + 12

    if (totalCount > 0) {
        cols := Min(totalCount, cardsPerRow)
        cardsW := (cols * cardWidth) + ((cols - 1) * spacing) + (padding * 2)
        width := Max(cardsW, wsBarW + 20)
        height := topOffset + (rowCount * cardHeight) + ((rowCount - 1) * spacing) + (padding * 2)
    } else {
        width := Max(360, wsBarW + 20)
        height := topOffset + 90
    }

    targetX := left + ((right - left - width) // 2)
    targetY := top + ((bottom - top - height) // 2)

    TabCardControls := []
    TopWorkspaceHeaderBtns := []

    btnBg := GetThemeColor("btn_bg")
    btnTxt := GetThemeColor("btn_txt")
    activeWS := CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1

    startXheader := (width - (wsBarW - 16)) // 2
    wsBarY := 12

    CustomTabGui.AddProgress("x" (startXheader - 8) " y" wsBarY " w" wsBarW " h" wsBarH " Background" GetThemeColor("bg_main") " Disabled")

    Loop WORKSPACE_COUNT {
        wsNum := A_Index
        hBtnX := startXheader + ((wsNum - 1) * (wsBtnW + wsGap))
        hBtnY := wsBarY + 6
        
        isCurrentWS := (wsNum = activeWS)
        hBgColor := isCurrentWS ? GetThemeColor("accent") : GetThemeColor("btn_bg")
        hTxtColor := isCurrentWS ? "FFFFFF" : GetThemeColor("btn_txt")

        hBg := CustomTabGui.AddProgress("x" hBtnX " y" hBtnY " w" wsBtnW " h" wsBtnH " Background" hBgColor " Disabled")
        
        CustomTabGui.SetFont("s8 c" hTxtColor " w700", "Segoe UI")
        hTxt := CustomTabGui.AddText("x" hBtnX " y" (hBtnY + 8) " w" wsBtnW " h" wsBtnH " Center BackgroundTrans", T("ov_default_prefix") " " wsNum)
        
        hOverlay := CustomTabGui.AddText("x" hBtnX " y" hBtnY " w" wsBtnW " h" wsBtnH " BackgroundTrans", " ")
        hOverlay.OnEvent("Click", OnTopWorkspaceSwitchClick.Bind(wsNum))

        TopWorkspaceHeaderBtns.Push({
            bg: hBg, txt: hTxt, overlay: hOverlay, wsNum: wsNum, isHovered: false, isActive: isCurrentWS
        })
    }

    if (totalCount = 0) {
        CustomTabGui.SetFont("s9 c" GetThemeColor("text_sub") " w600", "Segoe UI Variable Text")
        CustomTabGui.AddText("x" padding " y" (topOffset + padding + 15) " w" (width - (padding * 2)) " h30 Center BackgroundTrans", T("no_windows_msg"))
    } else {
        startXCards := (width - cardsW) // 2
        for idx, item in CustomTabList {
            isSelected := (idx = CustomTabIndex)

            column := Mod(idx - 1, cardsPerRow)
            row := (idx - 1) // cardsPerRow

            xPos := startXCards + padding + (column * (cardWidth + spacing))
            yPos := topOffset + padding + (row * (cardHeight + spacing))

            bgColor := isSelected ? GetThemeColor("bg_card_selected") : GetThemeColor("bg_card")
            bgCtrl := CustomTabGui.AddProgress(
                "x" xPos " y" yPos
                " w" cardWidth " h" cardHeight
                " Background" bgColor " Disabled"
            )

            iconPath := GetWindowIconPath(item.hwnd)
            picControl := 0

            try {
                picControl := CustomTabGui.AddPicture(
                    "x" (xPos + (cardWidth // 2) - 16)
                    " y" (yPos + 10)
                    " w32 h32 Icon1 BackgroundTrans",
                    iconPath
                )
            }

            dispTitle := (StrLen(item.title) > 15)
                ? SubStr(item.title, 1, 13) ".."
                : item.title

            textColor := "c" . (isSelected ? GetThemeColor("text_card_selected") : GetThemeColor("text_card"))

            CustomTabGui.SetFont("s8 " textColor " w700", "Segoe UI Variable Text")

            txtControl := CustomTabGui.AddText(
                "x" (xPos + 4)
                " y" (yPos + 46)
                " w" (cardWidth - 8)
                " h20 Center BackgroundTrans",
                dispTitle
            )

            wsBtnControls := []
            btnW := 20, btnH := 18, btnGap := 4
            
            cardWS := WindowWorkspace.Has(item.hwnd) ? WindowWorkspace[item.hwnd].workspace : activeWS

            visibleBtnCount := WORKSPACE_COUNT - 1
            if (visibleBtnCount < 1)
                visibleBtnCount := 1

            totalWsW := (visibleBtnCount * btnW) + ((visibleBtnCount - 1) * btnGap)
            startXws := xPos + ((cardWidth - totalWsW) // 2)

            btnIndex := 0
            Loop WORKSPACE_COUNT {
                wsNum := A_Index
                
                if (wsNum = cardWS)
                    continue

                btnIndex++
                btnX := startXws + ((btnIndex - 1) * (btnW + btnGap))
                btnY := yPos + 72

                wsBg := CustomTabGui.AddProgress(
                    "x" btnX " y" btnY " w" btnW " h" btnH " Background" btnBg " Disabled"
                )

                CustomTabGui.SetFont("s7 c" btnTxt " w700", "Segoe UI")
                wsTxt := CustomTabGui.AddText(
                    "x" btnX " y" (btnY + 2) " w" btnW " h" btnH " Center BackgroundTrans",
                    wsNum
                )

                wsOverlay := CustomTabGui.AddText(
                    "x" btnX " y" btnY " w" btnW " h" btnH " BackgroundTrans",
                    " "
                )
                wsOverlay.OnEvent("Click", OnMoveCardToWorkspaceClick.Bind(idx, wsNum))

                wsBtnControls.Push({
                    bg: wsBg,
                    txt: wsTxt,
                    overlay: wsOverlay,
                    wsNum: wsNum,
                    isHovered: false
                })
            }

            closeBtnBg := CustomTabGui.AddProgress(
                "x" (xPos + cardWidth - 22)
                " y" (yPos + 4)
                " w18 h18 Background" btnBg " Disabled"
            )

            CustomTabGui.SetFont("s7 c" btnTxt " w800", "Segoe UI")
            closeBtnTxt := CustomTabGui.AddText(
                "x" (xPos + cardWidth - 22)
                " y" (yPos + 5)
                " w18 h18 Center BackgroundTrans",
                "✕"
            )

            closeOverlay := CustomTabGui.AddText(
                "x" (xPos + cardWidth - 22)
                " y" (yPos + 4)
                " w18 h18 BackgroundTrans",
                " "
            )
            closeOverlay.OnEvent("Click", OnCloseCardClick.Bind(idx))

            clickOverlay := CustomTabGui.AddText(
                "x" xPos
                " y" (yPos + 8)
                " w" cardWidth
                " h60 BackgroundTrans",
                " "
            )
            clickOverlay.OnEvent("Click", OnTabCardClick.Bind(idx))

            TabCardControls.Push({
                bg: bgCtrl,
                pic: picControl,
                txt: txtControl,
                closeBg: closeBtnBg,
                closeTxt: closeBtnTxt,
                closeOverlay: closeOverlay,
                overlay: clickOverlay,
                wsBtns: wsBtnControls,
                isCloseHovered: false,
                index: idx,
                x: xPos, y: yPos, w: cardWidth, h: cardHeight
            })
        }
    }

    CustomTabGui.Show("NA x" targetX " y" targetY " w" width " h" height)

    if !CustomTabHoverTimerRunning {
        SetTimer(TrackCustomTabHover, 30)
        CustomTabHoverTimerRunning := true
    }

    try WinSetRegion(
        "0-0 W" width " H" height " R16-16",
        "ahk_id " CustomTabGui.Hwnd
    )
}

GetWindowIconPath(hwnd) {
    try {
        processPath := WinGetProcessPath("ahk_id " hwnd)
        if (processPath != "" && FileExist(processPath))
            return processPath
    }
    return A_WinDir "\System32\shell32.dll"
}

OnTopWorkspaceSwitchClick(targetWorkspace, *) {
    global CustomTabGui, CustomTabList, TabCardControls, TrayTabMode
    SwitchToWorkspace(targetWorkspace)
    CloseCustomTabPanel()
}

OnMoveCardToWorkspaceClick(index, targetWorkspace, *) {
    global CustomTabGui, CustomTabList, CustomTabIndex, TabCardControls, WindowWorkspace, HiddenByScript

    if (index <= CustomTabList.Length) {
        targetHwnd := CustomTabList[index].hwnd
        targetMon := GetMonitorUnderMouse()

        WindowWorkspace[targetHwnd] := {monitor: targetMon, workspace: targetWorkspace}
        
        HideWindowFast(targetHwnd)
        HiddenByScript[targetHwnd] := true

        try {
            appName := WinGetProcessName("ahk_id " targetHwnd)
            appName := RegExReplace(appName, "\.exe$", "")
        } catch {
            appName := (CURRENT_LANG = "TR") ? "Pencere" : "Window"
        }

        if (StrLen(appName) > 10)
            appName := SubStr(appName, 1, 8) ".."

        msgText := (CURRENT_LANG = "TR") ? (targetWorkspace . ". ALANA TAŞINDI") : ("MOVED TO WORKSPACE " . targetWorkspace)
        ShowWorkspaceOverlay(targetMon, msgText, 0, StrUpper(appName) " >")

        CloseCustomTabPanel()
    }
}

OnCloseCardClick(index, *) {
    global CustomTabList
    if (index <= CustomTabList.Length) {
        targetHwnd := CustomTabList[index].hwnd
        try WinActivate("ahk_id " targetHwnd)
        try WinClose("ahk_id " targetHwnd)
        CloseCustomTabPanel()
    }
}

OnMouseMove(wParam, lParam, msg, hwnd) {
    global CustomTabGui, CustomTabIndex, TabCardControls, TopWorkspaceHeaderBtns
    if !CustomTabGui
        return

    static lastHoveredHwnd := 0
    if (hwnd = lastHoveredHwnd)
        return
    lastHoveredHwnd := hwnd

    btnBgColor := GetThemeColor("btn_bg")
    btnTxtColor := GetThemeColor("btn_txt")
    accentHover := GetThemeColor("accent_hover")

    try {
        for hBtn in TopWorkspaceHeaderBtns {
            isHover := (hwnd = hBtn.overlay.Hwnd)
            if (isHover != hBtn.isHovered) {
                hBtn.isHovered := isHover
                if !hBtn.isActive {
                    if isHover {
                        hBtn.bg.Opt("+Background" accentHover)
                        hBtn.txt.SetFont("s8 cFFFFFF w700", "Segoe UI")
                    } else {
                        hBtn.bg.Opt("+Background" btnBgColor)
                        hBtn.txt.SetFont("s8 c" btnTxtColor " w700", "Segoe UI")
                    }
                    hBtn.txt.Redraw()
                    hBtn.overlay.Redraw()
                }
            }
        }

        for ctrlGroup in TabCardControls {
            isCloseHover := (hwnd = ctrlGroup.closeOverlay.Hwnd)
            if (isCloseHover != ctrlGroup.isCloseHovered) {
                ctrlGroup.isCloseHovered := isCloseHover
                if isCloseHover {
                    ctrlGroup.closeBg.Opt("+BackgroundEF4444")
                    ctrlGroup.closeTxt.SetFont("s7 cFFFFFF w800", "Segoe UI")
                } else {
                    ctrlGroup.closeBg.Opt("+Background" btnBgColor)
                    ctrlGroup.closeTxt.SetFont("s7 c" btnTxtColor " w800", "Segoe UI")
                }
                ctrlGroup.closeTxt.Redraw()
                ctrlGroup.closeOverlay.Redraw()
            }

            for wsBtn in ctrlGroup.wsBtns {
                isWsHover := (hwnd = wsBtn.overlay.Hwnd)
                if (isWsHover != wsBtn.isHovered) {
                    wsBtn.isHovered := isWsHover
                    if isWsHover {
                        wsBtn.bg.Opt("+Background" accentHover)
                        wsBtn.txt.SetFont("s7 cFFFFFF w800", "Segoe UI")
                    } else {
                        wsBtn.bg.Opt("+Background" btnBgColor)
                        wsBtn.txt.SetFont("s7 c" btnTxtColor " w800", "Segoe UI")
                    }
                    wsBtn.txt.Redraw()
                    wsBtn.overlay.Redraw()
                }
            }

            isCardHover := (hwnd = ctrlGroup.overlay.Hwnd || hwnd = ctrlGroup.txt.Hwnd || (ctrlGroup.pic && hwnd = ctrlGroup.pic.Hwnd))
            if isCardHover {
                if (CustomTabIndex != ctrlGroup.index) {
                    UpdateCustomTabSelection(ctrlGroup.index)
                }
            }
        }
    } catch {
        return
    }
}

TrackCustomTabHover() {
    global CustomTabGui, TabCardControls, CustomTabHoverTimerRunning, CustomTabIndex

    if !CustomTabGui {
        SetTimer(TrackCustomTabHover, 0)
        CustomTabHoverTimerRunning := false
        return
    }

    try {
        WinGetPos(&gx, &gy, &gw, &gh, "ahk_id " CustomTabGui.Hwnd)
        MouseGetPos(&mx, &my, &mouseWin, &mouseCtrl, 2)

        if (mx < gx || mx >= gx + gw || my < gy || my >= gy + gh)
            return

        localX := mx - gx
        localY := my - gy
        hoveredIndex := 0

        for card in TabCardControls {
            if (localX >= card.x && localX < card.x + card.w
                && localY >= card.y && localY < card.y + card.h) {
                hoveredIndex := card.index
                break
            }
        }

        if (hoveredIndex > 0 && hoveredIndex != CustomTabIndex)
            UpdateCustomTabSelection(hoveredIndex)
    } catch {
        return
    }
}

RedrawCardChildren(card) {
    try {
        if card.pic
            card.pic.Redraw()
        card.txt.Redraw()
        card.closeBg.Redraw()
        card.closeTxt.Redraw()
        card.closeOverlay.Redraw()
        for wsBtn in card.wsBtns {
            wsBtn.bg.Redraw()
            wsBtn.txt.Redraw()
            wsBtn.overlay.Redraw()
        }
        card.overlay.Redraw()
    }
}

UpdateCustomTabSelection(newIndex) {
    global CustomTabGui, CustomTabIndex, TabCardControls
    if !CustomTabGui || newIndex = CustomTabIndex || TabCardControls.Length = 0
        return

    oldIndex := CustomTabIndex
    CustomTabIndex := newIndex

    try {
        if (oldIndex > 0 && oldIndex <= TabCardControls.Length) {
            oldCard := TabCardControls[oldIndex]
            oldCard.bg.Opt("+Background" GetThemeColor("bg_card"))
            oldCard.txt.SetFont("s8 c" GetThemeColor("text_card") " w700", "Segoe UI Variable Text")
            RedrawCardChildren(oldCard)
        }

        if (newIndex > 0 && newIndex <= TabCardControls.Length) {
            newCard := TabCardControls[newIndex]
            newCard.bg.Opt("+Background" GetThemeColor("bg_card_selected"))
            newCard.txt.SetFont("s8 c" GetThemeColor("text_card_selected") " w700", "Segoe UI Variable Text")
            RedrawCardChildren(newCard)
        }
    }
}

OnTabCardClick(index, *) {
    global CustomTabGui, CustomTabList, TabCardControls, TrayTabMode
    if (CustomTabList.Length >= index) {
        targetHwnd := CustomTabList[index].hwnd
        try WinActivate("ahk_id " targetHwnd)
    }
    if CustomTabGui {
        CustomTabGui.Destroy()
        CustomTabGui := 0
        CustomTabList := []
        TabCardControls := []
    }
    TrayTabMode := false
    SetTimer(TrayTabOutsideClickCheck, 0)
    SetTimer(ForceFocusActiveWindow, -50)
}

; --- TEPSİ İKONUNA SOL TIK: ALT+TAB PANELİNİ AÇ ---
HandleTrayIconMessage(wParam, lParam, msg, hwnd) {
    global CustomTabGui, CustomTabList, CustomTabIndex, LastTabIndex, TrayTabMode, SettingsGui

    if (lParam = 0x0203) {
        ShowSettings()
        return
    }
	 if (lParam = 0x205) {
        CloseCustomTabPanel()
    }

    if (lParam != 0x0201)
        return

    if (CustomTabGui || (SettingsGui && WinExist("ahk_id " SettingsGui.Hwnd)))
        return

    TrayTabMode := true
    targetMonitor := GetMonitorUnderMouse()
    BuildCustomTabListForMonitor(targetMonitor)
    CustomTabIndex := 1
    LastTabIndex := 1
    ShowCustomTabMenu(targetMonitor)

    SetTimer(TrayTabOutsideClickCheck, 50)
}

BuildCustomTabListForMonitor(targetMonitor) {
    global CustomTabList, HiddenByScript, WindowWorkspace, CurrentWorkspace

    activeWS := CurrentWorkspace.Has(targetMonitor) ? CurrentWorkspace[targetMonitor] : 1
    CustomTabList := []

    for hwnd in WinGetList() {
        if HiddenByScript.Has(hwnd) || !IsManageableWindow(hwnd) || !IsVisible(hwnd)
            continue
        if (GetWindowMonitor(hwnd) != targetMonitor)
            continue
        if WindowWorkspace.Has(hwnd) && WindowWorkspace[hwnd].workspace != activeWS
            continue

        try title := WinGetTitle("ahk_id " hwnd)
        catch
            title := ""
        if (title != "")
            CustomTabList.Push({hwnd: hwnd, title: title})
    }
}

TrayTabOutsideClickCheck() {
    global CustomTabGui, TrayTabMode
    if !TrayTabMode || !CustomTabGui {
        SetTimer(TrayTabOutsideClickCheck, 0)
        return
    }

    if !GetKeyState("LButton", "P")
        return

    MouseGetPos(,, &mouseHwnd)
    if IsWindowInsideCustomTab(mouseHwnd)
        return

    CloseCustomTabPanel()
}

IsWindowInsideCustomTab(hwnd) {
    global CustomTabGui
    if !CustomTabGui || !hwnd
        return false
    try {
        root := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")
        return (root = CustomTabGui.Hwnd || hwnd = CustomTabGui.Hwnd)
    } catch {
        return false
    }
}

CloseCustomTabPanel() {
    global CustomTabGui, CustomTabList, TabCardControls, TopWorkspaceHeaderBtns, TrayTabMode, CustomTabHoverTimerRunning
    
    SetTimer(TrayTabOutsideClickCheck, 0)
    SetTimer(TrackCustomTabHover, 0)
    CustomTabHoverTimerRunning := false
    TrayTabMode := false

    if CustomTabGui {
        try CustomTabGui.Destroy()
        CustomTabGui := 0
    }
    
    CustomTabList := []
    TabCardControls := []
    TopWorkspaceHeaderBtns := []
}


~Alt Up:: {
    global CustomTabGui, CustomTabList, CustomTabIndex, TabCardControls

    if CustomTabGui && !TrayTabMode {
        if (CustomTabList.Length >= CustomTabIndex && CustomTabList.Length > 0) {
            targetHwnd := CustomTabList[CustomTabIndex].hwnd
            try WinActivate("ahk_id " targetHwnd)
        }
        CustomTabGui.Destroy()
        CustomTabGui := 0
        CustomTabList := []
        TabCardControls := []
    }
    SetTimer(ForceFocusActiveWindow, -50)
}

; --- SİSTEM TEPSİSİ MENÜSÜ ---
UpdateTrayMenu() {
    global CurrentWorkspace
	CloseCustomTabPanel()
    A_TrayMenu.Delete()

    A_TrayMenu.Add(T("tray_settings"), ShowSettings)
    A_TrayMenu.SetIcon(T("tray_settings"), GetIconPath(1001, "settings.ico"))

    A_TrayMenu.Add(T("tray_open_ahk"), OpenAHKLocation)
    A_TrayMenu.SetIcon(T("tray_open_ahk"), GetIconPath(1002, "folder.ico"))

    EnsureMonitorState()
    screenMenu := Menu()

    monitorCount := MonitorGetCount()
    Loop monitorCount {
        monitor := A_Index
        workspaceMenu := Menu()
        activeWorkspace := CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1

        Loop WORKSPACE_COUNT {
            workspace := A_Index
            itemText := T("tray_workspace") " " workspace
            workspaceMenu.Add(itemText, SwitchTrayMonitorWorkspace.Bind(monitor, workspace))
            if (workspace = activeWorkspace)
                workspaceMenu.Check(itemText)
        }

        screenText := T("tray_screen") " " monitor
        screenMenu.Add(screenText, workspaceMenu)
    }

    A_TrayMenu.Add(T("tray_screens"), screenMenu)
	A_TrayMenu.SetIcon(T("tray_screens"), GetIconPath(1021, "workspaces1.ico"))

    A_TrayMenu.Add(T("tray_reset"), ResetAndRevealAll)
    A_TrayMenu.SetIcon(T("tray_reset"), GetIconPath(1003, "reset.ico"))

    A_TrayMenu.Add(T("tray_help"), ShowHelp)
    A_TrayMenu.SetIcon(T("tray_help"), GetIconPath(1004, "help.ico"))
	
	A_TrayMenu.Add(T("tray_about"), ShowAbout)
	A_TrayMenu.SetIcon(T("tray_about"), GetIconPath(1025, "about.ico"))
	
    A_TrayMenu.Add()
	
	A_TrayMenu.Add(T("tray_uninstall"), UninstallProgram)
    A_TrayMenu.SetIcon(T("tray_uninstall"), GetIconPath(1023, "uninstall.ico"))

    A_TrayMenu.Add(T("tray_reload"), ScriptiYenidenBaslat)
    A_TrayMenu.SetIcon(T("tray_reload"), GetIconPath(1005, "reload.ico"))

    A_TrayMenu.Add(T("tray_exit"), (*) => ExitApp())
    A_TrayMenu.SetIcon(T("tray_exit"), GetIconPath(1006, "exit.ico"))

    A_IconTip := T("tray_tip")
}

ShowAbout(*) {
    aboutGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "WorkspaceSwitcher")
    
    ; Tema
    if (CURRENT_THEME = "DARK") {
        aboutGui.BackColor := "202020"
        titleColor := "FFFFFF"
        textColor := "D0D0D0"
    } else {
        aboutGui.BackColor := "F5F5F5"
        titleColor := "202020"
        textColor := "404040"
    }

    ; Başlık
    aboutGui.SetFont("s16 Bold c" titleColor, "Segoe UI")
    aboutGui.AddText("x20 y20 w360 h30 Center", "WorkspaceSwitcher")

    ; Alt başlık
    aboutGui.SetFont("s10 c" textColor, "Segoe UI")
    aboutGui.AddText("x20 y55 w360 h25 Center", "Independent Monitor Workspaces")

    ; Sürüm
    aboutGui.SetFont("s9 c" textColor, "Segoe UI")
    aboutGui.AddText("x20 y85 w360 h25 Center", "Version " APP_VERSION)

    ; Açıklama
    aboutGui.SetFont("s9 c" textColor, "Segoe UI")
    aboutGui.AddText(
        "x35 y125 w330 h40 Center",
        T("about_description")
    )

    ; Geliştirme bilgisi
    aboutGui.AddText(
        "x35 y170 w330 h25 Center",
        T("about_built")
    )

    ; Telif
    aboutGui.AddText(
        "x35 y200 w330 h25 Center",
        "© 2026 İzzettin ALPASLAN"
    )

	githubLink := aboutGui.AddText("x35 y217 w330 h25 Center", T("about_github"))
	githubLink.OnEvent("Click", (*) => Run("https://github.com/izzetalpha/WorkspaceSwitcher"))
	
    ; Kapat
    closeBtn := aboutGui.AddButton(
        "x140 y240 w120 h32",
        T("close")
    )

    closeBtn.OnEvent("Click", (*) => aboutGui.Destroy())
    aboutGui.OnEvent("Close", (*) => aboutGui.Destroy())
	

    aboutGui.Show("w400 h290 Center")
}

SwitchTrayMonitorWorkspace(monitor, workspace, *) {
    global WORKSPACE_COUNT, CurrentWorkspace, WindowWorkspace, HiddenByScript, Switching

    if workspace < 1 || workspace > WORKSPACE_COUNT
        return
    if Switching
        return

    Switching := true
    try {
        EnsureMonitorState()
        LearnVisibleWindows()

        oldWorkspace := CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1

        if workspace = oldWorkspace
            return

        direction := workspace > oldWorkspace ? 1 : -1

        ApplyMonitorWorkspace(monitor, workspace)
        CurrentWorkspace[monitor] := workspace
        ShowWorkspaceOverlay(monitor, workspace, direction)

        UpdateTrayMenu()
    } finally {
        Switching := false
    }
}

GetIconPath(resID, localFileName) {
    if !A_IsCompiled
        return A_ScriptDir "\icon\" localFileName

    hIcon := LoadEmbeddedIcon(resID, 32)

    if !hIcon
        throw Error("Embedded icon could not be loaded. Resource ID: " resID)

    return "HICON:" hIcon
}

LoadEmbeddedIcon(resID, size := 32) {
    hModule := DllCall("GetModuleHandle", "Ptr", 0, "Ptr")
    if !hModule
        return 0

    hIcon := DllCall("LoadImage", "Ptr", hModule, "Ptr", resID, "UInt", 1, "Int", size, "Int", size, "UInt", 0, "Ptr")
    return hIcon
}

ScriptiYenidenBaslat(*) {
    Reload()
}

OpenAHKLocation(*) {
    Run('explorer.exe /select,"' A_ScriptFullPath '"')
}

ShowFeedbackForMonitor(GetMonitorUnderMouse(), 1, T("ov_ready"))

OnWindowActivated(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    global CurrentWorkspace, WindowWorkspace, Switching
    
    if Switching || !hwnd || !IsManageableWindow(hwnd)
        return

    monitor := GetWindowMonitor(hwnd)
    if CurrentWorkspace.Has(monitor) {
        currentWS := CurrentWorkspace[monitor]
        WindowWorkspace[hwnd] := {monitor: monitor, workspace: currentWS}
    }
}

ForceFocusActiveWindow() {
    global Switching, CustomTabGui
    if Switching || CustomTabGui
        return

    hwnd := WinExist("A")
    if hwnd && IsManageableWindow(hwnd) {
        try WinActivate("ahk_id " hwnd)
    }
}

InitializeMonitors() {
    global CurrentWorkspace
    CurrentWorkspace.Clear()
    Loop MonitorGetCount()
        CurrentWorkspace[A_Index] := 1
}

SwitchToWorkspace(workspace, direction := 0, *) {
    global WORKSPACE_COUNT, CurrentWorkspace, WindowWorkspace, HiddenByScript, Switching

    if Type(direction) != "Integer"
        direction := 0

    if workspace < 1 || workspace > WORKSPACE_COUNT
        return
    if Switching
        return

    Switching := true
    try {
        EnsureMonitorState()
        monitor := GetMonitorUnderMouse()
        oldWorkspace := CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1

        LearnVisibleWindows()

        if workspace = oldWorkspace {
            ShowWorkspaceOverlay(monitor, workspace, 0)
            return
        }

        if direction = 0
            direction := workspace > oldWorkspace ? 1 : -1

        ApplyMonitorWorkspace(monitor, workspace)
        CurrentWorkspace[monitor] := workspace

        UpdateTrayMenu()

        ShowWorkspaceOverlay(monitor, workspace, direction)
    } finally {
        Switching := false
    }
}

ApplyMonitorWorkspace(monitor, targetWorkspace) {
    global WindowWorkspace, HiddenByScript

    lastMovedHwnd := 0

    for hwnd, slot in WindowWorkspace.Clone() {
        if !WinExist("ahk_id " hwnd) {
            ForgetWindow(hwnd)
            continue
        }
        if slot.monitor != monitor
            continue

        if slot.workspace = targetWorkspace {
            if HiddenByScript.Has(hwnd) {
                ShowWindowFast(hwnd)
                HiddenByScript.Delete(hwnd)
            }
            if slot.HasOwnProp("isTop") && slot.isTop {
                lastMovedHwnd := hwnd
                slot.isTop := false
            }
        } else if IsVisible(hwnd) && IsManageableWindow(hwnd) {
            HideWindowFast(hwnd)
            HiddenByScript[hwnd] := true
        }
    }

    if lastMovedHwnd && WinExist("ahk_id " lastMovedHwnd) {
        try {
            WinActivate("ahk_id " lastMovedHwnd)
        }
    }
}

PreviousWorkspace(*) {
    global CurrentWorkspace
    EnsureMonitorState()
    monitor := GetMonitorUnderMouse()
    current := CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1
    next := current - 1

    if next < 1 {
        ShowWorkspaceOverlay(monitor, "", 0, T("ov_first"))
        return
    }
    SwitchToWorkspace(next, -1)
}

NextWorkspace(*) {
    global WORKSPACE_COUNT, CurrentWorkspace
    EnsureMonitorState()
    monitor := GetMonitorUnderMouse()
    current := CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1
    next := current + 1

    if next > WORKSPACE_COUNT {
        ShowWorkspaceOverlay(monitor, "", 0, T("ov_last"))
        return
    }
    SwitchToWorkspace(next, 1)
}

MoveTopWindowToWorkspace(workspace, *) {
    global WORKSPACE_COUNT, CurrentWorkspace, WindowWorkspace, HiddenByScript

    if workspace < 1 || workspace > WORKSPACE_COUNT
        return

    EnsureMonitorState()
    monitor := GetMonitorUnderMouse()
    
    hwnd := GetTopWindowOnMonitor(monitor)
    if !hwnd
        return

    WindowWorkspace[hwnd] := {monitor: monitor, workspace: workspace, isTop: true}

    try {
        appName := WinGetProcessName("ahk_id " hwnd)
        appName := RegExReplace(appName, "\.exe$", "")
    } catch {
        appName := (CURRENT_LANG = "TR") ? "PENCERE" : "WINDOW"
    }

    if (StrLen(appName) > 10)
        appName := SubStr(appName, 1, 8) ".."

    currentActiveWS := CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1
    if workspace = currentActiveWS {
        if HiddenByScript.Has(hwnd) {
            ShowWindowFast(hwnd)
            HiddenByScript.Delete(hwnd)
        }
        try WinActivate("ahk_id " hwnd)
    } else {
        HideWindowFast(hwnd)
        HiddenByScript[hwnd] := true
    }

    msgText := (CURRENT_LANG = "TR") ? (workspace . T("ov_moved")) : (T("ov_moved") . " " . workspace)
    ShowWorkspaceOverlay(monitor, msgText, 0, StrUpper(appName) " >")
}

GetTopWindowOnMonitor(targetMonitor) {
    global HiddenByScript
    
    for hwnd in WinGetList() {
        if HiddenByScript.Has(hwnd)
            continue
        if !IsManageableWindow(hwnd) || !IsVisible(hwnd)
            continue

        if GetWindowMonitor(hwnd) = targetMonitor
            return hwnd
    }
    return 0
}

LearnVisibleWindows() {
    global CurrentWorkspace, WindowWorkspace, HiddenByScript

    for hwnd in WinGetList() {
        if HiddenByScript.Has(hwnd)
            continue
        if !IsManageableWindow(hwnd) || !IsVisible(hwnd)
            continue

        monitor := GetWindowMonitor(hwnd)
        activeWs := CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1

        if !WindowWorkspace.Has(hwnd) {
            WindowWorkspace[hwnd] := {
                monitor: monitor,
                workspace: activeWs
            }
            continue
        }

        slot := WindowWorkspace[hwnd]
        if slot.monitor != monitor {
            WindowWorkspace[hwnd] := {
                monitor: monitor,
                workspace: activeWs
            }
        }
    }
}

IsManageableWindow(hwnd) {
    global HiddenByScript

    if hwnd = A_ScriptHwnd
        return false

    try style := WinGetStyle("ahk_id " hwnd)
    catch
        return false

    if style & 0x40000000
        return false

    try class := WinGetClass("ahk_id " hwnd)
    catch
        return false

    static ignoredClasses := Map(
        "Shell_TrayWnd", true,
        "Shell_SecondaryTrayWnd", true,
        "Progman", true,
        "WorkerW", true,
        "DV2ControlHost", true,
        "MsgrIMEWindowClass", true,
        "SysShadow", true,
        "Windows.UI.Core.CoreWindow", true,
        "AutoHotkeyGUI", true,
        "MultitaskingViewFrame", true
    )
    if ignoredClasses.Has(class)
        return false

    if !HiddenByScript.Has(hwnd) && !(style & 0x10000000)
        return false

    try {
        cloaked := 0
        if DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 14,
            "int*", &cloaked, "uint", 4) = 0 && cloaked
            return false
    }

    return true
}

IsVisible(hwnd) {
    try return DllCall("IsWindowVisible", "ptr", hwnd, "int") != 0
    catch
        return false
}

HideWindowFast(hwnd) {
    try DllCall("ShowWindowAsync", "ptr", hwnd, "int", 0)
}

ShowWindowFast(hwnd) {
    try DllCall("ShowWindowAsync", "ptr", hwnd, "int", 8)
}

InitializeKnownWindows() {
    global KnownWindows
    KnownWindows.Clear()
    for hwnd in WinGetList() {
        KnownWindows[hwnd] := true
    }
}

CheckNewWindows() {
    global MOUSE_SCREEN_WINDOWS, KnownWindows, CustomTabGui, SettingsGui, WorkspaceOverlays

    if !MOUSE_SCREEN_WINDOWS
        return

    currentWindows := Map()
    for hwnd in WinGetList() {
        currentWindows[hwnd] := true

        if KnownWindows.Has(hwnd)
            continue

        if !IsWindowReadyForMouseScreen(hwnd)
            continue

        KnownWindows[hwnd] := true
        MoveNewWindowToMouseScreen(hwnd)
    }

    for hwnd in KnownWindows.Clone() {
        if !currentWindows.Has(hwnd)
            KnownWindows.Delete(hwnd)
    }
}

IsWindowReadyForMouseScreen(hwnd) {
    global SettingsGui

    if !hwnd || hwnd = A_ScriptHwnd
        return false
    if SettingsGui && hwnd = SettingsGui.Hwnd
        return false
    if !WinExist("ahk_id " hwnd)
        return false
    if !IsVisible(hwnd)
        return false

    try class := WinGetClass("ahk_id " hwnd)
    catch
        return false

    static ignoredClasses := Map(
        "Shell_TrayWnd", true,
        "Shell_SecondaryTrayWnd", true,
        "Progman", true,
        "WorkerW", true,
        "DV2ControlHost", true,
        "Windows.UI.Core.CoreWindow", true,
        "AutoHotkeyGUI", true,
        "MultitaskingViewFrame", true,
        "#32768", true,
        "tooltips_class32", true,
        "NotifyIconOverflowWindow", true
    )

    if ignoredClasses.Has(class)
        return false

    try style := WinGetStyle("ahk_id " hwnd)
    catch
        return false

    if style & 0x40000000
        return false

    try {
        cloaked := 0
        if DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 14,
            "int*", &cloaked, "uint", 4) = 0 && cloaked
            return false
    }

    return true
}

MoveNewWindowToMouseScreen(hwnd) {
    if !WinExist("ahk_id " hwnd)
        return

    targetMonitor := GetMonitorUnderMouse()
    currentMonitor := GetWindowMonitor(hwnd)

    if currentMonitor = targetMonitor
        return

    try {
        WinGetPos(&winX, &winY, &winW, &winH, "ahk_id " hwnd)
    } catch {
        return
    }

    try state := WinGetMinMax("ahk_id " hwnd)
    catch
        state := 0

    if state != 0 {
        try WinRestore("ahk_id " hwnd)
        Sleep(30)
        try WinGetPos(&winX, &winY, &winW, &winH, "ahk_id " hwnd)
    }

    MonitorGetWorkArea(targetMonitor, &left, &top, &right, &bottom)
    workW := right - left
    workH := bottom - top

    newW := Min(winW, workW)
    newH := Min(winH, workH)
    newX := left + ((workW - newW) // 2)
    newY := top + ((workH - newH) // 2)

    try WinMove(newX, newY, newW, newH, "ahk_id " hwnd)
}

GetMonitorUnderMouse() {
    point := Buffer(8, 0)
    if !DllCall("GetCursorPos", "ptr", point.Ptr)
        return MonitorGetPrimary()

    hMonitor := DllCall("MonitorFromPoint", "int64", NumGet(point, 0, "int64"),
        "uint", 2, "ptr")
    return GetMonitorIndexFromHandle(hMonitor)
}

GetWindowMonitor(hwnd) {
    hMonitor := DllCall("MonitorFromWindow", "ptr", hwnd, "uint", 2, "ptr")
    return GetMonitorIndexFromHandle(hMonitor)
}

GetMonitorIndexFromHandle(hMonitor) {
    if !hMonitor
        return MonitorGetPrimary()

    info := Buffer(104, 0)
    NumPut("uint", 104, info, 0)
    if !DllCall("GetMonitorInfoW", "ptr", hMonitor, "ptr", info.Ptr)
        return MonitorGetPrimary()

    deviceName := StrGet(info.Ptr + 40, 32, "UTF-16")
    Loop MonitorGetCount() {
        if StrLower(MonitorGetName(A_Index)) = StrLower(deviceName)
            return A_Index
    }
    return MonitorGetPrimary()
}

EnsureMonitorState() {
    global CurrentWorkspace
    count := MonitorGetCount()
    Loop count {
        if !CurrentWorkspace.Has(A_Index)
            CurrentWorkspace[A_Index] := 1
    }
}

ForgetWindow(hwnd) {
    global WindowWorkspace, HiddenByScript
    if WindowWorkspace.Has(hwnd)
        WindowWorkspace.Delete(hwnd)
    if HiddenByScript.Has(hwnd)
        HiddenByScript.Delete(hwnd)
}

HandleDisplayChange(*) {
    SetTimer(ResetAfterDisplayChange, -750)
}

ResetAfterDisplayChange() {
    global Switching
    if Switching {
        SetTimer(ResetAfterDisplayChange, -300)
        return
    }
    ResetAndRevealAll()
}

RestoreAllWindows(*) {
    global HiddenByScript
    for hwnd in HiddenByScript.Clone() {
        if WinExist("ahk_id " hwnd)
            ShowWindowFast(hwnd)
    }
    HiddenByScript.Clear()
}

ResetAndRevealAll(*) {
    global CurrentWorkspace, WindowWorkspace
    RestoreAllWindows()
    WindowWorkspace.Clear()
    CurrentWorkspace.Clear()
    InitializeMonitors()
    ShowWorkspaceOverlay(GetMonitorUnderMouse(), "", 0, T("ov_reset"))
}

ShowWorkspaceOverlay(monitor, workspace, direction := 0, prefix := "") {
    global SHOW_FEEDBACK, WORKSPACE_COUNT, ANIMATION_MS, WorkspaceOverlays
    if !SHOW_FEEDBACK
        return

    if (prefix = "")
        prefix := T("ov_default_prefix")

    CancelWorkspaceOverlay(monitor)
    MonitorGetWorkArea(monitor, &left, &top, &right, &bottom)

    label := (workspace = "") ? prefix 
        : direction > 0 ? prefix " " workspace "  ›"
        : direction < 0 ? "‹  " prefix " " workspace
        : prefix " " workspace

    fontSize := (StrLen(label) > 20) ? 11 : 14
    width := (StrLen(label) > 20) ? 360 : 300
    height := 95
    
    targetX := left + ((right - left - width) // 2)
    targetY := top + 42
    startX := targetX + (direction * 90)

    overlay := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 -DPIScale")
    overlay.BackColor := GetThemeColor("bg_main")
    overlay.MarginX := 0
    overlay.MarginY := 0
    
    overlay.SetFont("s9 c9CA3AF w600", "Segoe UI")
    overlay.AddText("x10 y10 w" (width - 20) " h18 Center BackgroundTrans", T("ov_monitor") . monitor)
    
    txtColor := "c" . GetThemeColor("text_main")
    overlay.SetFont("s" fontSize " " txtColor " w600", "Segoe UI Variable Display")
    overlay.AddText("x5 y30 w" (width - 10) " h30 Center BackgroundTrans", label)

    activeDot := (workspace != "" && IsNumber(workspace)) ? Number(workspace) : (CurrentWorkspace.Has(monitor) ? CurrentWorkspace[monitor] : 1)
    dots := ""
    Loop WORKSPACE_COUNT
        dots .= (A_Index = activeDot ? "●" : "○") "  "
    overlay.SetFont("s9 c60A5FA w600", "Segoe UI Symbol")
    overlay.AddText("x10 y64 w" (width - 20) " h20 Center BackgroundTrans", RTrim(dots))

    overlay.Show("NA x" startX " y" targetY " w" width " h" height)
    hwnd := overlay.Hwnd

    try WinSetRegion("0-0 W" width " H" height " R18-18", "ahk_id " hwnd)
    try WinSetTransparent(0, "ahk_id " hwnd)

    state := {
        gui: overlay, hwnd: hwnd, monitor: monitor,
        startX: startX, targetX: targetX, y: targetY,
        started: A_TickCount, duration: ANIMATION_MS
    }
    state.moveTimer := AnimateWorkspaceOverlay.Bind(state)
    WorkspaceOverlays[monitor] := state
    SetTimer(state.moveTimer, 16)
}

AnimateWorkspaceOverlay(state) {
    global WorkspaceOverlays
    if !WorkspaceOverlays.Has(state.monitor)
        return
    if WorkspaceOverlays[state.monitor].hwnd != state.hwnd
        return

    t := Min(1, (A_TickCount - state.started) / state.duration)
    ease := 1 - ((1 - t) ** 3)
    x := state.startX + ((state.targetX - state.startX) * ease)
    alpha := Round(238 * Min(1, t / 0.45))
    try WinMove(Round(x), state.y,,, "ahk_id " state.hwnd)
    try WinSetTransparent(alpha, "ahk_id " state.hwnd)

    if t >= 1 {
        SetTimer(state.moveTimer, 0)
        SetTimer(BeginWorkspaceOverlayFade.Bind(state), -650)
    }
}

BeginWorkspaceOverlayFade(state) {
    global WorkspaceOverlays
    if !WorkspaceOverlays.Has(state.monitor)
        return
    if WorkspaceOverlays[state.monitor].hwnd != state.hwnd
        return

    state.fadeStarted := A_TickCount
    state.fadeTimer := FadeWorkspaceOverlay.Bind(state)
    SetTimer(state.fadeTimer, 16)
}

FadeWorkspaceOverlay(state) {
    global WorkspaceOverlays
    if !WorkspaceOverlays.Has(state.monitor)
        return
    if WorkspaceOverlays[state.monitor].hwnd != state.hwnd
        return

    t := Min(1, (A_TickCount - state.fadeStarted) / 150)
    try WinSetTransparent(Round(238 * (1 - t)), "ahk_id " state.hwnd)
    if t >= 1 {
        SetTimer(state.fadeTimer, 0)
        CancelWorkspaceOverlay(state.monitor)
    }
}

CancelWorkspaceOverlay(monitor) {
    global WorkspaceOverlays
    if !WorkspaceOverlays.Has(monitor)
        return

    state := WorkspaceOverlays[monitor]
    try SetTimer(state.moveTimer, 0)
    if state.HasOwnProp("fadeTimer")
        try SetTimer(state.fadeTimer, 0)
    try state.gui.Destroy()
    WorkspaceOverlays.Delete(monitor)
}

ShowFeedbackForMonitor(monitor, workspace, prefix := "") {
    if (prefix = "")
        prefix := T("ov_default_prefix")
    ShowWorkspaceOverlay(monitor, workspace, 0, StrUpper(prefix))
}

; --- AYARLAR PENCERESİ ---
GetRes(id, file, size := 32) {
    if !A_IsCompiled
        return A_ScriptDir "\icon\" file

    hIcon := LoadEmbeddedIcon(id, size)

    if !hIcon
        throw Error("Embedded icon could not be loaded. Resource ID: " id)

    return "HICON:" hIcon
}

global SettingsGui := 0

ShowSettings(*) {
	CloseCustomTabPanel()
    global WORKSPACE_COUNT, SHOW_FEEDBACK, ANIMATION_MS, CURRENT_LANG, CURRENT_THEME, MOUSE_SCREEN_WINDOWS, SettingsGui

    if (SettingsGui && WinExist("ahk_id " SettingsGui.Hwnd)) {
        WinActivate("ahk_id " SettingsGui.Hwnd)
        return
    }

    cBgGui := GetThemeColor("bg_gui")
    cBgBox := GetThemeColor("bg_box")
    cTextMain := GetThemeColor("text_main")
    cTextSub := GetThemeColor("text_sub")
    cTextInfo := GetThemeColor("text_info")
    cAccent := GetThemeColor("accent")
    cBorder := GetThemeColor("border")

	SettingsGui := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox -DPIScale", T("set_title"))
    SettingsGui.OnEvent("Close", (*) => (SettingsGui.Destroy(), SettingsGui := 0))
    SettingsGui.BackColor := cBgGui

    if (CURRENT_THEME = "DARK") {
        try DllCall("dwmapi\DwmSetWindowAttribute", "ptr", settingsGui.Hwnd, "int", 20, "int*", 1, "int", 4)
    }

    settingsGui.SetFont("s28 c" cAccent, "Segoe UI Symbol")
    settingsGui.Add("Picture", "x25 y15 w40 h40 BackgroundTrans", GetRes(1008, "color-settings.ico"))

    settingsGui.SetFont("s16 Bold c" cTextMain, "Segoe UI")
    settingsGui.Add("Text", "x80 y20 w550 BackgroundTrans", T("set_header"))

    settingsGui.SetFont("s10 Norm c" cTextSub, "Segoe UI")
    settingsGui.Add("Text", "x80 y52 w580 BackgroundTrans", T("set_sub"))

    ; Ayarlar penceresi kutu yüksekliği yeni seçenekle birlikte 490 yapıldı
    settingsGui.Add("GroupBox", "x25 y85 w630 h490")

    settingsGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    settingsGui.Add("Picture", "x40 y115 w25 h25 BackgroundTrans", GetRes(1019, "workspaces.ico"))

    settingsGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    settingsGui.Add("Text", "x75 y107 w200 BackgroundTrans", T("set_ws_count"))

    settingsGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    settingsGui.Add("Text", "x75 y127 w240 BackgroundTrans", T("set_ws_count_desc"))

    settingsGui.SetFont("s9 Norm", "Segoe UI")
    ddlWsCount := settingsGui.Add("DropDownList", "x442 y110 w120 Choose" WORKSPACE_COUNT, ["1", "2", "3", "4", "5"])
	
	settingsGui.Add("Text", "x40 y148 w600 h1 Background" cBorder)

	settingsGui.Add("Picture", "x40 y165 w25 h25 BackgroundTrans", GetRes(1022, "windowstomouse.ico"))

    settingsGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    settingsGui.Add("Text", "x75 y157 w350 BackgroundTrans", T("set_mouse_screen"))

    settingsGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    settingsGui.Add("Text", "x75 y177 w350 BackgroundTrans", T("set_mouse_screen_desc"))

    settingsGui.SetFont("s9 Norm c" cTextMain, "Segoe UI")
    chkMouseScreen := settingsGui.Add("Checkbox", "x442 y165 w120 h24 " . (MOUSE_SCREEN_WINDOWS ? "Checked" : ""), T("set_feedback_active"))

    settingsGui.Add("Text", "x40 y205 w600 h1 Background" cBorder)

    ; --- BAŞLANGIÇTA AÇILSIN AYARI ---
    startupShortcut := A_Startup "\" A_ScriptName ".lnk"
    isStartupExists := FileExist(startupShortcut) ? "Checked" : ""

    settingsGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    settingsGui.Add("Picture", "x40 y225 w25 h25 BackgroundTrans", GetRes(1024, "runatstartup.ico"))

    settingsGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    settingsGui.Add("Text", "x75 y217 w350 BackgroundTrans", T("set_startup"))

    settingsGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    settingsGui.Add("Text", "x75 y237 w350 BackgroundTrans", T("set_startup_desc"))

    settingsGui.SetFont("s9 Norm c" cTextMain, "Segoe UI")
    chkStartup := settingsGui.Add("Checkbox", "x442 y225 w120 h24 " . isStartupExists, T("set_feedback_active"))

    settingsGui.Add("Text", "x40 y265 w600 h1 Background" cBorder)
    ; ---------------------------------

    settingsGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    settingsGui.Add("Picture", "x40 y285 w25 h25 BackgroundTrans", GetRes(1017, "screen-notify.ico"))

    settingsGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    settingsGui.Add("Text", "x75 y277 w200 BackgroundTrans", T("set_feedback"))

    settingsGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    settingsGui.Add("Text", "x75 y297 w240 BackgroundTrans", T("set_feedback_desc"))

    settingsGui.SetFont("s9 Norm c" cTextMain, "Segoe UI")
    chkFeedback := settingsGui.Add("Checkbox", "x442 y280 w120 h24 " . (SHOW_FEEDBACK ? "Checked" : ""), T("set_feedback_active"))

    settingsGui.Add("Text", "x40 y325 w600 h1 Background" cBorder)

    settingsGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    settingsGui.Add("Picture", "x40 y345 w25 h25 BackgroundTrans", GetRes(1010, "duration.ico"))

    settingsGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    settingsGui.Add("Text", "x75 y337 w200 BackgroundTrans", T("set_anim"))

    settingsGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    settingsGui.Add("Text", "x75 y357 w240 BackgroundTrans", T("set_anim_desc"))

    settingsGui.SetFont("s9 Norm", "Segoe UI")
    edtAnimMs := settingsGui.Add("Edit", "x442 y340 w120 Number", ANIMATION_MS)

    settingsGui.Add("Text", "x40 y385 w600 h1 Background" cBorder)

    settingsGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    settingsGui.Add("Picture", "x40 y395 w25 h25 BackgroundTrans", GetRes(1014, "language.ico"))

    settingsGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    settingsGui.Add("Text", "x75 y387 w200 BackgroundTrans", T("set_lang"))

    settingsGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    settingsGui.Add("Text", "x75 y407 w240 BackgroundTrans", T("set_lang_desc"))

    settingsGui.SetFont("s9 Norm", "Segoe UI")
    langChoice := (CURRENT_LANG = "EN") ? 2 : 1
    ddlLang := settingsGui.Add("DropDownList", "x442 y400 w120 Choose" langChoice, ["Türkçe", "English"])

    settingsGui.Add("Text", "x40 y445 w600 h1 Background" cBorder)

    settingsGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    settingsGui.Add("Picture", "x40 y455 w25 h25 BackgroundTrans", GetRes(1018, "theme.ico"))

    settingsGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    settingsGui.Add("Text", "x75 y447 w200 BackgroundTrans", T("set_theme"))

    settingsGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    settingsGui.Add("Text", "x75 y467 w240 BackgroundTrans", T("set_theme_desc"))

    settingsGui.SetFont("s9 Norm", "Segoe UI")
    themeChoice := (CURRENT_THEME = "LIGHT") ? 2 : 1
    ddlTheme := settingsGui.Add("DropDownList", "x442 y460 w120 Choose" themeChoice, [T("set_theme_dark"), T("set_theme_light")])

    ; Bilgi paneli ve buton konumları yeni yüksekliğe göre güncellendi
    settingsGui.Add("Progress", "x25 y590 w630 h54 Background" cBgBox " Disabled")
    
    settingsGui.SetFont("s11 c" cAccent, "Segoe UI Symbol")
    settingsGui.Add("Picture", "x35 y605 w25 h25 BackgroundTrans", GetRes(1013, "info-lamp.ico"))

    settingsGui.SetFont("s8 Bold c" cTextInfo, "Segoe UI")
    settingsGui.Add("Text", "x65 y603 w585 BackgroundTrans", T("set_info_title"))
    
    settingsGui.SetFont("s8 Norm c" cTextInfo, "Segoe UI")
    settingsGui.Add("Text", "x65 y619 w585 BackgroundTrans", T("set_info_desc"))

    btnKaydet := settingsGui.Add("Button", "x405 y660 w120 h32 Default", T("btn_save"))
   	btnKaydet.OnEvent("Click", (*) => (SaveSettings(SettingsGui, ddlWsCount.Value, chkFeedback.Value, edtAnimMs.Value, ddlLang.Text, ddlTheme.Value, chkMouseScreen.Value, chkStartup.Value), SettingsGui := 0))
	
    btnIptal := settingsGui.Add("Button", "x535 y660 w120 h32", T("btn_cancel"))
    btnIptal.OnEvent("Click", (*) => (SettingsGui.Destroy(), SettingsGui := 0))

    SettingsGui.Show("w680 h715")
}

SaveSettings(guiObj, wsVal, fbVal, animVal, langVal, themeIdx, mouseScreenVal, startupVal) {
    global WORKSPACE_COUNT, SHOW_FEEDBACK, ANIMATION_MS, CURRENT_LANG, CURRENT_THEME, MOUSE_SCREEN_WINDOWS, KnownWindows

    WORKSPACE_COUNT := wsVal
    SHOW_FEEDBACK := fbVal ? true : false
    ANIMATION_MS := (animVal != "" && Number(animVal) > 0) ? Number(animVal) : 180
    CURRENT_LANG := (langVal = "English") ? "EN" : "TR"
    CURRENT_THEME := (themeIdx = 2) ? "LIGHT" : "DARK"
    MOUSE_SCREEN_WINDOWS := mouseScreenVal ? true : false

    ; Başlangıç kısayolu yönetimi
    startupShortcut := A_Startup "\" A_ScriptName ".lnk"
    if (startupVal == 1) {
        if !FileExist(startupShortcut) {
            FileCreateShortcut(A_ScriptFullPath, startupShortcut)
        }
    } else {
        if FileExist(startupShortcut) {
            FileDelete(startupShortcut)
        }
    }

    InitializeKnownWindows()
    SetTimer(CheckNewWindows, MOUSE_SCREEN_WINDOWS ? 200 : 0)

    UpdateTrayMenu()
    guiObj.Destroy()
    
    mon := GetMonitorUnderMouse()
    ShowFeedbackForMonitor(mon, CurrentWorkspace.Has(mon) ? CurrentWorkspace[mon] : 1, T("msg_saved"))
}

; --- KULLANIM REHBERİ ---
ShowHelp(*) {
	CloseCustomTabPanel()
    global WORKSPACE_COUNT

    cBgGui := GetThemeColor("bg_gui")
    cBgBox := GetThemeColor("bg_box")
    cTextMain := GetThemeColor("text_main")
    cTextSub := GetThemeColor("text_sub")
    cTextInfo := GetThemeColor("text_info")
    cAccent := GetThemeColor("accent")
    cBorder := GetThemeColor("border")

    helpGui := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox -DPIScale", T("help_title"))
    helpGui.BackColor := cBgGui

    if (CURRENT_THEME = "DARK") {
        try DllCall("dwmapi\DwmSetWindowAttribute", "ptr", helpGui.Hwnd, "int", 20, "int*", 1, "int", 4)
    }

    helpGui.SetFont("s28 c" cAccent, "Segoe UI Symbol")
    helpGui.Add("Picture", "x25 y20 w40 h40 BackgroundTrans", GetRes(1012, "info.ico"))

    helpGui.SetFont("s16 Bold c" cTextMain, "Segoe UI")
    helpGui.Add("Text", "x80 y20 w550 BackgroundTrans", T("help_header"))

    helpGui.SetFont("s10 Norm c" cTextSub, "Segoe UI")
    helpGui.Add("Text", "x80 y52 w580 BackgroundTrans", T("help_sub"))

    helpGui.Add("GroupBox", "x25 y85 w630 h425")

    AddKeyBadge(targetGui, x, y, text, minWidth := 32) {
        cKeyBg := GetThemeColor("bg_key")
        cKeyTxt := GetThemeColor("text_key")

        w := Max(minWidth, StrLen(text) * 7 + 16)
        h := 22

        if (x + w > 635) {
            w := 635 - x
        }

        bg := targetGui.AddText("x" x " y" y " w" w " h" h " Background" cKeyBg)
        try WinSetRegion("0-0 W" w " H" h " R6-6", "ahk_id " bg.Hwnd)

        targetGui.SetFont("s8 Bold c" cKeyTxt, "Segoe UI")
        txt := targetGui.AddText("x" x " y" (y + 3) " w" w " h" h " Center BackgroundTrans", text)
        
        return x + w + 4
    }

    AddPlusSymbol(targetGui, x, y) {
        cSub := GetThemeColor("text_sub")
        targetGui.SetFont("s9 Bold c" cSub, "Segoe UI")
        targetGui.Add("Text", "x" x " y" (y + 2) " w14 Center BackgroundTrans", "+")
        return x + 14
    }

    helpGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    helpGui.Add("Picture", "x40 y105 w30 h30 BackgroundTrans", GetRes(1020, "workspace-switch.ico"))

    helpGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    helpGui.Add("Text", "x75 y107 w180 BackgroundTrans", T("help_sec1"))

    helpGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    helpGui.Add("Text", "x75 y127 w200 BackgroundTrans", T("help_sec1_desc"))

    kx := 300, ky := 107
    kx := AddKeyBadge(helpGui, kx, ky, "Ctrl")
    kx := AddPlusSymbol(helpGui, kx, ky)
    kx := AddKeyBadge(helpGui, kx, ky, "Win")
    kx := AddPlusSymbol(helpGui, kx, ky)
    AddKeyBadge(helpGui, kx, ky, "← / →")

    helpGui.Add("Text", "x40 y148 w600 h1 Background" cBorder)

    helpGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    helpGui.Add("Picture", "x40 y163 w30 h30 BackgroundTrans", GetRes(1011, "fast-workspace-switch.ico"))

    helpGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    helpGui.Add("Text", "x75 y160 w180 BackgroundTrans", T("help_sec2"))

    helpGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    helpGui.Add("Text", "x75 y180 w200 BackgroundTrans", T("help_sec2_desc"))

    kx := 300, ky := 160
    kx := AddKeyBadge(helpGui, kx, ky, T("help_sec2_btn1"))
    kx := AddPlusSymbol(helpGui, kx, ky)
    AddKeyBadge(helpGui, kx, ky, T("help_sec2_btn2"))

    helpGui.Add("Text", "x40 y201 w600 h1 Background" cBorder)

    helpGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    helpGui.Add("Picture", "x40 y213 w30 h30 BackgroundTrans", GetRes(1007, "active-workspace.ico"))

    helpGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    helpGui.Add("Text", "x75 y213 w180 BackgroundTrans", T("help_sec3"))

    helpGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    helpGui.Add("Text", "x75 y233 w200 BackgroundTrans", T("help_sec3_desc"))

    kx := 300, ky := 213
    kx := AddKeyBadge(helpGui, kx, ky, "Alt")
    kx := AddPlusSymbol(helpGui, kx, ky)
    kx := AddKeyBadge(helpGui, kx, ky, "Tab")

    helpGui.SetFont("s8 c" cTextSub, "Segoe UI")
    helpGui.Add("Text", "x" (kx + 6) " y" (ky + 4) " w180 BackgroundTrans", T("help_sec3_sub"))

    helpGui.Add("Text", "x40 y254 w600 h1 Background" cBorder)

    helpGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    helpGui.Add("Picture", "x40 y269 w30 h30 BackgroundTrans", GetRes(1015, "move-window.ico"))

    helpGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    helpGui.Add("Text", "x75 y266 w180 BackgroundTrans", T("help_sec4"))

    helpGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    helpGui.Add("Text", "x75 y286 w200 BackgroundTrans", T("help_sec4_desc"))

    kx := 300, ky := 266
    kx := AddKeyBadge(helpGui, kx, ky, "Win")
    kx := AddPlusSymbol(helpGui, kx, ky)
    kx := AddKeyBadge(helpGui, kx, ky, "Ctrl")
    kx := AddPlusSymbol(helpGui, kx, ky)
    AddKeyBadge(helpGui, kx, ky, "Numpad 1-" . WORKSPACE_COUNT)

    helpGui.Add("Text", "x40 y307 w600 h1 Background" cBorder)

    helpGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    helpGui.Add("Picture", "x40 y322 w30 h30 BackgroundTrans", GetRes(1009, "direct-workspace-switch.ico"))

    helpGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    helpGui.Add("Text", "x75 y319 w180 BackgroundTrans", T("help_sec5"))

    helpGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    helpGui.Add("Text", "x75 y339 w200 BackgroundTrans", T("help_sec5_desc"))

    kx := 300, ky := 319
    kx := AddKeyBadge(helpGui, kx, ky, "Ctrl")
    kx := AddPlusSymbol(helpGui, kx, ky)
    kx := AddKeyBadge(helpGui, kx, ky, "Win")
    kx := AddPlusSymbol(helpGui, kx, ky)
    AddKeyBadge(helpGui, kx, ky, "1 - " . WORKSPACE_COUNT)

    helpGui.Add("Text", "x40 y360 w600 h1 Background" cBorder)

    helpGui.SetFont("s18 c" cAccent, "Segoe UI Symbol")
    helpGui.Add("Picture", "x40 y375 w30 h30 BackgroundTrans", GetRes(1016, "reset-show.ico"))

    helpGui.SetFont("s10 Bold c" cAccent, "Segoe UI")
    helpGui.Add("Text", "x75 y372 w180 BackgroundTrans", T("help_sec6"))

    helpGui.SetFont("s9 Norm c" cTextSub, "Segoe UI")
    helpGui.Add("Text", "x75 y392 w200 BackgroundTrans", T("help_sec6_desc"))

    kx := 300, ky := 372
    kx := AddKeyBadge(helpGui, kx, ky, "Ctrl")
    kx := AddPlusSymbol(helpGui, kx, ky)
    kx := AddKeyBadge(helpGui, kx, ky, "Win")
    kx := AddPlusSymbol(helpGui, kx, ky)
    kx := AddKeyBadge(helpGui, kx, ky, "Shift")
    kx := AddPlusSymbol(helpGui, kx, ky)
    AddKeyBadge(helpGui, kx, ky, "Esc")

    helpGui.Add("Progress", "x25 y520 w630 h54 Background" cBgBox " Disabled")
    
    helpGui.SetFont("s11 c" cAccent, "Segoe UI Symbol")
    helpGui.Add("Picture", "x30 y534 w30 h30 BackgroundTrans", GetRes(1013, "info-lamp.ico"))

    helpGui.SetFont("s8 Bold c" cTextInfo, "Segoe UI")
    helpGui.Add("Text", "x65 y526 w580 BackgroundTrans", T("help_tip_title"))
    
    helpGui.SetFont("s8 Norm c" cTextInfo, "Segoe UI")
    helpGui.Add("Text", "x65 y541 w580 BackgroundTrans", T("help_tip_desc1"))
    helpGui.Add("Text", "x65 y556 w580 BackgroundTrans", T("help_tip_desc2"))    

    btnTamam := helpGui.Add("Button", "x535 y578 w120 h32 Default", T("btn_understand"))
    btnTamam.OnEvent("Click", (*) => helpGui.Destroy())

    helpGui.Show("w680 h620")
}
