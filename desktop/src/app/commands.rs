use std::fs;

use crate::types::List;

#[tauri::command]
pub fn load() -> Vec<List> {
    let mut lists: Vec<List> = vec![];
    for file in fs::read_dir(".data").unwrap() {
        let file = file.unwrap();
        if file.path().is_dir() {
            break;
        }
        let content = fs::read_to_string(file.path()).unwrap();
        // serde_json::from_str("")
        let list: List = serde_json::from_str(&content).unwrap();
        lists.push(list);
    }
    lists
}

#[tauri::command]
pub fn save(list: List) -> List {
    let file_path = format!(".data/{}", &list.id);
    // let file_contents = serde_json::to_string(&list).unwrap();
    let file_contents = serde_json::to_string_pretty(&list).unwrap();
    fs::write(file_path, file_contents).unwrap();
    println!("save");
    list
}
