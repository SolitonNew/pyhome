#!/usr/bin/python3

from http.server import BaseHTTPRequestHandler, HTTPServer

class HttpProcessor(BaseHTTPRequestHandler):    
    def do_GET(self):
        print(self.headers)
        self.send_response(200)
        self.send_header('content-type','text/html')
        self.end_headers()
        self.wfile.write("ZZZZZ".encode("utf-8"))


if __name__ == "__main__":
    serv = HTTPServer(("localhost", 8082), HttpProcessor)
    serv.serve_forever()
