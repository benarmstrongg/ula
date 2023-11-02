use std::time::Duration;

use zeroconf::{prelude::*, MdnsBrowser, NetworkInterface, ServiceDiscoveredCallback, ServiceType};

use super::Browser;

pub struct HttpBrowser {
    service_name: String,
}

impl HttpBrowser {
    pub fn new(service_name: &str) -> Self {
        HttpBrowser {
            service_name: service_name.into(),
        }
    }
}

impl Browser for HttpBrowser {
    fn browse(&self, on_service_discovered: Box<ServiceDiscoveredCallback>) {
        let mut browser = MdnsBrowser::new(ServiceType::new(&self.service_name, "tcp").unwrap());
        browser.set_service_discovered_callback(Box::new(on_service_discovered));
        browser.set_network_interface(NetworkInterface::Unspec);

        let event_loop = browser.browse_services().unwrap();

        println!("browsing services");

        loop {
            // calling `poll()` will keep this browser alive
            event_loop.poll(Duration::from_secs(0)).unwrap();
        }
    }

    fn service_name(&self) -> String {
        self.service_name.clone()
    }
}
