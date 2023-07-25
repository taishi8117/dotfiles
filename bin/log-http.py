import http.server
import socketserver
import logging


class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.log_request_details()
        self.send_response(200)
        self.end_headers()

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        content = self.rfile.read(content_length) if content_length > 0 else b""
        self.log_request_details(content)
        self.send_response(200)
        self.end_headers()

    def log_request_details(self, content=b""):
        logging.info(f"Request headers:\n{self.headers}")
        if content:
            logging.info(f"Request content:\n{content.decode('utf-8')}\n")


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
    )
    port = 4444
    handler = CustomHTTPRequestHandler
    httpd = socketserver.TCPServer(("", port), handler)
    logging.info(f"Serving on port {port}")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logging.info("Server stopped.")
