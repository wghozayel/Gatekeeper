#!/usr/bin/python
# -*- coding: iso-8859-1 -*-

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import urlparse
import json
import subprocess
import datetime
import RPi.GPIO as GPIO
import os, time, re, sys
from subprocess import Popen
import cgi
from urllib import urlencode

# Define server address and port, use localhost if you are running this on your Mattermost server.
HOSTNAME = '192.168.150.1'
PORT = 80

# guarantee unicode string
_u = lambda t: t.decode('UTF-8', 'replace') if isinstance(t, str) else t

class PostHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        args = {}
        idx = self.path.find('?')
        if idx >= 0:
            rpath = self.path[:idx]
            args = cgi.parse_qs(self.path[idx+1:])
        else:
            rpath = self.path

        # Get the file path.
        basepath = "/var/www/html/"
        path = basepath + rpath
        dirpath = None
        # If it is a directory look for index.html
        # or process it directly if there are 3
        # trailing slashed.
        if os.path.exists(path) and os.path.isdir(path):
            dirpath = path  # the directory portion
            index_files = ['index.html', 'index.htm', ]
            for index_file in index_files:
                tmppath = dirpath + index_file
                if os.path.exists(tmppath):
                    path = tmppath
                    break


        if 'id' in args:
            hidPattern = re.compile("HID Prox TAG ID:\s([a-z,A-Z,0-9]+)\s\(")
            indalaPattern = re.compile(" \((.........)\)")

            cloneOut = subprocess.check_output(["/usr/bin/expect", '-f' '/root/proxmark3/scan/clone.sh',args['id'][0]])
            scanOut = Popen(["/usr/bin/expect", '-f' '/root/proxmark3/scan/scan.sh'],stdout=subprocess.PIPE)

            raw = str(scanOut.communicate()[0])
            lines = raw.splitlines()
            tag = None

            for line in lines:
                hidMatch = re.match(hidPattern, line)
                indalaMatch = re.match(indalaPattern, line)
                if hidMatch:
                    tag = hidMatch.group(1)
                elif indalaMatch:
                    tag = indalaMatch.group(1)

            if tag==args['id'][0]:
                if os.path.exists(basepath + 'success.html'):
                    self.send_response(302)
                    self.send_header('Location', 'success.html')
                    self.end_headers()
                    return
            else:
                if os.path.exists(basepath + 'failure.txt'):
                    with open(basepath + 'failure.txt', 'w+') as err_file:
                        err_file.write(raw)
                    self.send_response(302)
                    self.send_header('Location', 'failure.txt')
                    self.end_headers()


        if os.path.exists(path) and os.path.isfile(path):
            # This is valid file, send it as the response
            # after determining whether it is a type that
            # the server recognizes.
            _, ext = os.path.splitext(path)
            ext = ext.lower()
            content_type = {
                '.css': 'text/css',
                '.gif': 'image/gif',
                '.htm': 'text/html',
                '.html': 'text/html',
                '.jpeg': 'image/jpeg',
                '.jpg': 'image/jpg',
                '.js': 'text/javascript',
                '.png': 'image/png',
                '.text': 'text/plain',
                '.txt': 'text/plain',
                '.csv': 'text/csv',
                '.woff2': '',
                '.ico': 'image/x-icon',
            }
            # If it is a known extension, set the correct
            # content type in the response.
            if ext in content_type:
                self.send_response(200)  # OK
                if ext in ['.css','.js','.woff2','.ico']:
                    self.send_header('Cache-Control', 'max-age=3110400')
                    self.send_header('Expires', 'Mon, 13 Aug 2199 15:10:03 GMT')
                self.send_header('Content-type', content_type[ext])
                self.end_headers()
                with open(path) as ifp:
                    self.wfile.write(ifp.read())
        elif dirpath is not None:
            # List the directory contents. Allow simple navigation.
            self.send_response(200)  # OK
            self.send_header('Content-type', 'text/html')
            self.end_headers()

            self.wfile.write('<html>')
            self.wfile.write('  <head>')
            self.wfile.write('    <title>%s</title>' % (dirpath))
            self.wfile.write('  </head>')
            self.wfile.write('  <body>')
            self.wfile.write('    <a href="%s">Home</a><br>' % ('/'));
            # Make the directory path navigable.
            dirstr = ''
            href = None
            for seg in rpath.split('/'):
                if href is None:
                    href = seg
                else:
                    href = href + '/' + seg
                    dirstr += '/'
                dirstr += '<a href="%s">%s</a>' % (href, seg)
            self.wfile.write('<p>Directory: %s</p>' % (dirstr))
            # Write out the simple directory list (name and size).
            self.wfile.write('<table border="0">')
            self.wfile.write('<tbody>')
            fnames = ['..']
            fnames.extend(sorted(os.listdir(dirpath), key=str.lower))
            for fname in fnames:
                self.wfile.write('<tr>')
                self.wfile.write('<td align="left">')
                path = rpath + '/' + fname
                fpath = os.path.join(dirpath, fname)
                if os.path.isdir(path):
                    self.wfile.write('<a href="%s">%s/</a>' % (path, fname))
                else:
                    self.wfile.write('<a href="%s">%s</a>' % (path, fname))
                self.wfile.write('<td></td>')
                self.wfile.write('</td>')
                self.wfile.write('<td align="right">%d</td>' % (os.path.getsize(fpath)))
                self.wfile.write('</tr>')
            self.wfile.write('</tbody>')
            self.wfile.write('</table>')
            self.wfile.write('</body>')
            self.wfile.write('</html>')
        else:
            if dirpath is None :
                # Invalid file path, respond with a server access error
                self.send_response(500)  # generic server error for now
                self.send_header('Content-type', 'text/html')
                self.end_headers()

                self.wfile.write('<html>')
                self.wfile.write('<head>')
                self.wfile.write('<title>Server Access Error</title>')
                self.wfile.write('</head>')
                self.wfile.write('<body>')
                self.wfile.write('<p>Server access error.</p>')
                self.wfile.write('<p>%r</p>' % (repr(self.path)))
                self.wfile.write('<p><a href="%s">Back</a></p>' % (rpath))
                self.wfile.write('</body>')
                self.wfile.write('</html>')



if __name__ == '__main__':
    server = HTTPServer((HOSTNAME, PORT), PostHandler)
    print('Starting Gatekeeper server, use <Ctrl-C> to stop')
    #This was because I was seeing cards come in as all 0's until a clone was done.
    cloneOut = subprocess.check_output(["/usr/bin/expect", '-f' '/root/proxmark3/scan/clone.sh','00'])
    scanOut = Popen(["/usr/bin/expect", '-f' '/root/proxmark3/scan/scan.sh'],stdout=subprocess.PIPE)
    server.serve_forever()

