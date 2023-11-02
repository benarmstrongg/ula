// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]
use std::any::Any;
use std::net::TcpStream;
use std::sync::Arc;
use zeroconf::ServiceDiscovery;

mod app;
mod net;
mod types;

use net::http::HttpBrowser;
use net::Browser;

fn main() {
    std::thread::spawn(|| {
        HttpBrowser::new("listapp").browse(Box::new(on_service_discovered));
    });

    app::init();
}

fn on_service_discovered(
    result: zeroconf::Result<ServiceDiscovery>,
    _context: Option<Arc<dyn Any>>,
) {
    let service = result.unwrap();
    println!("Service discovered: {:?}", service);
    if service.name() == "OK" {
        let addr = format!("{}:{}", service.address(), service.port());
        TcpStream::connect(addr).unwrap();
    }

    // ...
}

// #[derive(Default, Debug)]
// pub struct Context {
//     service_name: String,
// }

// fn main2() {
//     std::thread::spawn(|| {
//         let mut service = MdnsService::new(ServiceType::new("listapp", "tcp").unwrap(), 8080);
//         let context: Arc<Mutex<Context>> = Arc::default();

//         service.set_name("test");
//         service.set_registered_callback(Box::new(on_service_registered));
//         service.set_context(Box::new(context));

//         let event_loop = service.register().unwrap();

//         println!("registered service");

//         loop {
//             // calling `poll()` will keep this service alive
//             event_loop.poll(Duration::from_secs(0)).unwrap();
//         }
//     });

//     app::init();
// }

// fn on_service_registered(
//     result: zeroconf::Result<ServiceRegistration>,
//     context: Option<Arc<dyn Any>>,
// ) {
//     let service = result.unwrap();

//     println!("Service registered: {:?}", service);

//     let context = context
//         .as_ref()
//         .unwrap()
//         .downcast_ref::<Arc<Mutex<Context>>>()
//         .unwrap()
//         .clone();

//     context.lock().unwrap().service_name = service.name().clone();

//     println!("Context: {:?}", context);

//     std::thread::spawn(|| {
//         let listener = TcpListener::bind("127.0.0.1:8080").unwrap();
//         println!("registered listener");

//         for connection in listener.incoming() {
//             let mut stream = connection.unwrap_or_else(|err| panic!("tcp connect err {:?}", err));
//             // let mut buf = String::new();
//             // let n = stream
//             //     .read_to_string(&mut buf)
//             //     .unwrap_or_else(|err| panic!("tcp read err {:?}", err));
//             // println!("{:?} {:?}", n, buf);
//             // std::thread::sleep(Duration::from_secs(2));
//             stream
//                 .write("hello back".as_bytes())
//                 .unwrap_or_else(|err| panic!("tcp write err {:?}", err));
//             std::thread::sleep(Duration::from_secs(2));
//         }
//     });
// }
