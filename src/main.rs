// use std::{io::Cursor, sync::Arc};

// use inputbot::{KeybdKey, handle_input_events};
// use rodio::{Decoder, OutputStream, Sink};

// const SOUND_DATA_YAUUGH: &[u8] = include_bytes!("sounds/yauugh.wav");
// const SOUND_DATA_BRUH: &[u8] = include_bytes!("sounds/bruh.wav");
// const SOUND_DATA_SLAP: &[u8] = include_bytes!("sounds/slap.wav");
// const SOUND_DATA_GETOUT: &[u8] = include_bytes!("sounds/getout.wav");

// fn main() {
//     let (_stream, stream_handle) = OutputStream::try_default().unwrap();
//     let sink = Arc::new(Sink::try_new(&stream_handle).unwrap());

//     KeybdKey::SlashKey.bind(move || {
//         if KeybdKey::LShiftKey.is_pressed() || KeybdKey::RShiftKey.is_pressed() {
//             play_sound(Arc::clone(&sink), SOUND_DATA_SLAP);
//         }
//     });

//     KeybdKey::EnterKey.bind(move || {
//         play_sound(Arc::clone(&sink), SOUND_DATA_YAUUGH);
//     });

//     handle_input_events();
// }

// fn play_sound(sink: Arc<Sink>, data: &[u8]) {
//     let cursor = Cursor::new(data.to_vec());
//     let source = Decoder::new(cursor).unwrap();

//     sink.skip_one(); // perfect
//     sink.append(source);
// }

use std::{
    io::Cursor,
    sync::{Arc, Mutex},
};

use rdev::{Event, EventType, Key, listen};
use rodio::{Decoder, OutputStream, Sink};

const SOUND_DATA_YAUUGH: &[u8] = include_bytes!("sounds/yauugh.wav");
const SOUND_DATA_BRUH: &[u8] = include_bytes!("sounds/bruh.wav");
const SOUND_DATA_SLAP: &[u8] = include_bytes!("sounds/slap.wav");
const SOUND_DATA_GETOUT: &[u8] = include_bytes!("sounds/getout.wav");
const SOUND_DATA_BOOM: &[u8] = include_bytes!("sounds/boom.wav");
const SOUND_DATA_FART: &[u8] = include_bytes!("sounds/fart.wav");

fn main() {
    let (_stream, stream_handle) = OutputStream::try_default().unwrap();
    let sink = Arc::new(Mutex::new(Sink::try_new(&stream_handle).unwrap()));

    if let Err(error) = listen(move |event| callback(event, &sink)) {
        println!("Error: {:?}", error);
    }
}

fn callback(event: Event, sink: &Arc<Mutex<Sink>>) {
    match event.event_type {
        EventType::KeyPress(key) => {
            play_sound(sink, key);
        }
        _ => {}
    }
}

fn play_sound(sink: &Arc<Mutex<Sink>>, key: Key) {
    let sound_data = match key {
        Key::Return => Some(SOUND_DATA_YAUUGH),
        Key::Backspace => Some(SOUND_DATA_BRUH),
        Key::Tab => Some(SOUND_DATA_SLAP),
        Key::Delete => Some(SOUND_DATA_GETOUT),
        Key::Escape => Some(SOUND_DATA_FART),
        Key::Space => Some(SOUND_DATA_BOOM),
        _ => None,
    };

    if let Some(data) = sound_data {
        let cursor = Cursor::new(data);
        let source = Decoder::new(cursor).unwrap();

        let sink = sink.lock().unwrap();

        sink.skip_one(); // perfect
        sink.append(source);
    }
}
