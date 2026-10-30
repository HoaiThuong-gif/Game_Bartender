"""Private-subnet TLS transport and device credentials for the local scanner."""
from datetime import datetime, timedelta, timezone
import hashlib
import hmac
import ipaddress
from pathlib import Path
import secrets
import ssl
import threading
from http.server import ThreadingHTTPServer

PRIVATE = tuple(ipaddress.ip_network(value) for value in ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'))


def private_address(value):
    address = ipaddress.IPv4Address(value)
    if address != ipaddress.IPv4Address('127.0.0.1') and not any(address in network for network in PRIVATE):
        raise ValueError('Bind to a specific RFC1918 LAN IPv4 address, never 0.0.0.0 or a public address.')
    return address


class LanIdentity:
    def __init__(self, host, subnet):
        from cryptography import x509
        from cryptography.hazmat.primitives import hashes, serialization
        from cryptography.hazmat.primitives.asymmetric import rsa
        from cryptography.x509.oid import NameOID
        address = private_address(host)
        self.subnet = ipaddress.ip_network(subnet, strict=False)
        if self.subnet.version != 4 or address not in self.subnet or not (
                any(self.subnet.subnet_of(n) for n in PRIVATE) or
                (str(address) == '127.0.0.1' and str(self.subnet) == '127.0.0.1/32')):
            raise ValueError('The client subnet must contain the bind address and stay inside RFC1918 space.')
        root = Path(__file__).resolve().parents[1]/'.scan-runtime/network'
        root.mkdir(parents=True, exist_ok=True)
        secret = root/'pairing.key'
        if not secret.exists():
            with secret.open('x', encoding='ascii') as output:
                output.write(secrets.token_urlsafe(24))
            secret.chmod(0o600)
        self.secret = secret.read_text(encoding='ascii').strip()
        self.server_id = hashlib.sha256(self.secret.encode()).hexdigest()[:32]
        cert_file, key_file = root/f'{address}-usb.pem', root/f'{address}-usb.key'
        regenerate = not cert_file.exists() or not key_file.exists()
        if not regenerate:
            cert = x509.load_pem_x509_certificate(cert_file.read_bytes())
            regenerate = cert.not_valid_after_utc < datetime.now(timezone.utc)+timedelta(days=7)
        if regenerate:
            key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
            subject = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, 'Local object scanner')])
            now = datetime.now(timezone.utc)
            cert = (x509.CertificateBuilder().subject_name(subject).issuer_name(subject)
                    .public_key(key.public_key()).serial_number(x509.random_serial_number())
                    .not_valid_before(now-timedelta(days=1)).not_valid_after(now+timedelta(days=365))
                    .add_extension(x509.SubjectAlternativeName([
                        x509.IPAddress(ip) for ip in {address, ipaddress.IPv4Address('127.0.0.1')}
                    ]), critical=False)
                    .sign(key, hashes.SHA256()))
            key_file.write_bytes(key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8,
                                                   serialization.NoEncryption()))
            key_file.chmod(0o600)
            cert_file.write_bytes(cert.public_bytes(serialization.Encoding.PEM))
        self.pairing_code = cert.fingerprint(hashes.SHA256()).hex()+'.'+self.secret
        self.tls = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        self.tls.minimum_version = ssl.TLSVersion.TLSv1_2
        self.tls.load_cert_chain(str(cert_file), str(key_file))

    def device_token(self, device):
        return hmac.new(self.secret.encode(), device.encode(), hashlib.sha256).hexdigest()


class LanHTTPServer(ThreadingHTTPServer):
    daemon_threads = True
    request_queue_size = 8

    def __init__(self, address, handler, identity):
        self.identity = identity
        self.connections = threading.BoundedSemaphore(8)
        super().__init__(address, handler)

    def verify_request(self, request, address):
        return (address[0] == '127.0.0.1' and self.server_address[0] == '127.0.0.1' or
                ipaddress.ip_address(address[0]) in self.identity.subnet)

    def get_request(self):
        connection, address = super().get_request()
        connection.settimeout(30)
        try:
            return self.identity.tls.wrap_socket(connection, server_side=True, do_handshake_on_connect=False), address
        except Exception:
            connection.close()
            raise

    def process_request(self, request, address):
        if not self.connections.acquire(blocking=False):
            request.close()
            return
        try:
            super().process_request(request, address)
        except Exception:
            self.connections.release()
            raise

    def process_request_thread(self, request, address):
        try:
            super().process_request_thread(request, address)
        finally:
            self.connections.release()
