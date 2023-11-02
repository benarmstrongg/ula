use zeroconf::ServiceRegisteredCallback;

pub trait Listener {
    fn listen(&mut self, name: &str, port: u16) -> Self;
    fn on_service_registered(&mut self) -> Box<ServiceRegisteredCallback>;
    fn service_type(&self) -> String;
}
