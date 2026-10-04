"""Northstar Repairs: internal repair-job tracking. Python standard library only."""
import base64, hashlib, hmac, html, os, secrets, sqlite3
from contextlib import contextmanager
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs
DB=os.environ.get('DB_PATH','jobs.sqlite')
USER=os.environ.get('APP_USER','owner')
PASSWORD=os.environ['APP_PASSWORD']
TOKEN=secrets.token_urlsafe(32)
@contextmanager
def connect():
    c=sqlite3.connect(DB,timeout=10)
    try:
        c.execute('PRAGMA journal_mode=WAL')
        with c:
            yield c
    finally:
        c.close()
with connect() as c:
    c.execute('CREATE TABLE IF NOT EXISTS jobs(id INTEGER PRIMARY KEY, customer TEXT NOT NULL, device TEXT NOT NULL, status TEXT NOT NULL DEFAULT "Received", created TEXT DEFAULT CURRENT_TIMESTAMP)')
class Handler(BaseHTTPRequestHandler):
    def reply(self,code,body,typ='text/html; charset=utf-8'):
        b=body.encode(); self.send_response(code)
        for k,v in {'Content-Type':typ,'Content-Length':str(len(b)),'Cache-Control':'no-store','X-Content-Type-Options':'nosniff','Content-Security-Policy':"default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; frame-ancestors 'none'"}.items(): self.send_header(k,v)
        self.end_headers(); self.wfile.write(b)
    def auth(self):
        expected='Basic '+base64.b64encode(f'{USER}:{PASSWORD}'.encode()).decode()
        if hmac.compare_digest(self.headers.get('Authorization',''),expected): return True
        self.send_response(401); self.send_header('WWW-Authenticate','Basic realm="Northstar"'); self.end_headers(); return False
    def do_GET(self):
        if self.path=='/health':
            try:
                with connect() as c: c.execute('SELECT count(*) FROM jobs').fetchone()
                return self.reply(200,'ok','text/plain')
            except sqlite3.Error: return self.reply(503,'database unavailable','text/plain')
        if not self.auth(): return
        if self.path!='/': return self.reply(404,'Not found')
        with connect() as c: rows=c.execute('SELECT id,customer,device,status,created FROM jobs ORDER BY id DESC').fetchall()
        esc=lambda x: html.escape(str(x),quote=True)
        body=''.join('<tr>'+''.join('<td>'+esc(x)+'</td>' for x in row)+f'<td><form method="post" action="/status"><input type="hidden" name="token" value="{TOKEN}"><input type="hidden" name="id" value="{row[0]}"><select name="status"><option>Received</option><option>In progress</option><option>Ready</option><option>Collected</option></select><button>Update</button></form></td></tr>' for row in rows)
        self.reply(200,f"""<!doctype html><html lang="en"><meta charset="utf-8"><title>Northstar Repairs</title><style>body{{font:16px system-ui;max-width:1100px;margin:40px auto;padding:20px;background:#f3f6fa;color:#172b4d}}table{{width:100%;border-collapse:collapse;background:white}}td,th{{text-align:left;padding:12px;border-bottom:1px solid #ddd}}input,select,button{{padding:8px;margin:4px}}button{{background:#155e75;color:white;border:0}}</style><h1>Northstar Repairs</h1><p>Repair intake and collection tracker · synthetic lab data only</p><form method="post" action="/jobs"><input type="hidden" name="token" value="{TOKEN}"><input name="customer" maxlength="100" placeholder="Customer alias" required><input name="device" maxlength="160" placeholder="Device / issue" required><button>Create repair job</button></form><table><tr><th>Job</th><th>Customer</th><th>Device / issue</th><th>Status</th><th>Created UTC</th><th>Action</th></tr>{body}</table></html>""")
    def do_POST(self):
        if not self.auth(): return
        try:
            n=int(self.headers.get('Content-Length','0'))
            if n<1 or n>4096: return self.reply(413,'Invalid body size')
            data=parse_qs(self.rfile.read(n).decode(),strict_parsing=True)
            val=lambda k:data[k][0]
            if not hmac.compare_digest(val('token'),TOKEN): return self.reply(403,'Reload page and try again')
            with connect() as c:
                if self.path=='/jobs':
                    customer,device=val('customer').strip(),val('device').strip()
                    if not (0<len(customer)<=100 and 0<len(device)<=160): return self.reply(400,'Invalid fields')
                    c.execute('INSERT INTO jobs(customer,device) VALUES(?,?)',(customer,device))
                elif self.path=='/status':
                    status=val('status')
                    if status not in ('Received','In progress','Ready','Collected'): return self.reply(400,'Invalid status')
                    c.execute('UPDATE jobs SET status=? WHERE id=?',(status,int(val('id'))))
                else: return self.reply(404,'Not found')
            self.send_response(303); self.send_header('Location','/'); self.end_headers()
        except (KeyError,ValueError,UnicodeError): self.reply(400,'Invalid request')
if __name__=='__main__':
    ThreadingHTTPServer((os.environ.get('APP_HOST','127.0.0.1'),int(os.environ.get('APP_PORT','8080'))),Handler).serve_forever()
