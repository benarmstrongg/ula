use tauri::{AppHandle, CustomMenuItem, Manager, SystemTray, SystemTrayEvent, SystemTrayMenu};

mod menu_items {
    pub const SHOW: &str = "show";
    pub const QUIT: &str = "quit";
}

pub fn create_system_tray() -> SystemTray {
    let tray_menu = SystemTrayMenu::new()
        .add_item(CustomMenuItem::new(menu_items::SHOW, "Show window"))
        .add_item(CustomMenuItem::new(menu_items::QUIT, "Quit ul"));
    SystemTray::new().with_menu(tray_menu)
}

pub fn on_system_tray_event(app: &AppHandle, event: SystemTrayEvent) {
    match event {
        SystemTrayEvent::MenuItemClick { id, .. } => match id.as_str() {
            menu_items::QUIT => app.exit(0),
            menu_items::SHOW => {
                app.get_window("main").unwrap().show().unwrap();
            }
            _ => {}
        },
        _ => {}
    };
}
