use flutter_rust_bridge::frb;

#[frb]
pub async fn pick_music_folder() -> Option<String> {
    rfd::AsyncFileDialog::new()
        .set_title("Add music folder")
        .pick_folder()
        .await
        .map(|handle| handle.path().to_string_lossy().into_owned())
}

#[frb]
pub async fn pick_bex_file() -> Option<String> {
    rfd::AsyncFileDialog::new()
        .set_title("Install .bex plugin")
        .add_filter("Bloomee plugin", &["bex"])
        .pick_file()
        .await
        .map(|handle| handle.path().to_string_lossy().into_owned())
}
