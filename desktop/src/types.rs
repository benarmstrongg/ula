use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct List {
    pub id: Box<str>,
    pub name: Box<str>,
    pub items: Box<[ListItem]>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ListItem {
    pub id: Box<str>,
    pub content: Box<str>,
    pub is_completed: bool,
}
