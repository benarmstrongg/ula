use super::commands;
use super::system_tray;

pub fn init() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![commands::load, commands::save])
        .system_tray(system_tray::create_system_tray())
        .on_system_tray_event(system_tray::on_system_tray_event)
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

// .on_window_event(|event| match event.event() {
//     tauri::WindowEvent::CloseRequested { api, .. } => {
//         event.window().hide().unwrap();
//         api.prevent_close();
//     }
//     _ => {}
// })
