use zeroconf::ServiceDiscoveredCallback;

pub trait Browser {
    fn browse(&self, on_service_discovered: Box<ServiceDiscoveredCallback>);
    fn service_name(&self) -> String;
}
