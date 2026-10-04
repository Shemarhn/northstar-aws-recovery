import base64, http.client, os, re, socket, subprocess, sys, tempfile, time, unittest
from pathlib import Path
class AppTest(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.tmp=tempfile.TemporaryDirectory()
  with socket.socket() as s: s.bind(('127.0.0.1',0)); cls.port=s.getsockname()[1]
  env=dict(os.environ,APP_PASSWORD='test-only-password',APP_PORT=str(cls.port),DB_PATH=str(Path(cls.tmp.name)/'jobs.sqlite'))
  cls.proc=subprocess.Popen([sys.executable,str(Path(__file__).resolve().parents[1]/'app/server.py')],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
  for _ in range(50):
   try:
    if cls.request('GET','/health')[0]==200: break
   except OSError: time.sleep(.1)
  else: raise RuntimeError('App did not start')
 @classmethod
 def tearDownClass(cls): cls.proc.terminate(); cls.proc.wait(); cls.tmp.cleanup()
 @classmethod
 def request(cls,method,path,body=None,auth=False):
  c=http.client.HTTPConnection('127.0.0.1',cls.port,timeout=5)
  headers={'Content-Type':'application/x-www-form-urlencoded'}
  if auth: headers['Authorization']='Basic '+base64.b64encode(b'owner:test-only-password').decode()
  c.request(method,path,body,headers); r=c.getresponse(); result=(r.status,r.read().decode()); c.close(); return result
 def test_workflow_and_controls(self):
  from urllib.parse import urlencode
  self.assertEqual(self.request('GET','/')[0],401)
  page=self.request('GET','/',auth=True)[1]
  token=re.search('name="token" value="([^"]+)"',page)[1]
  self.assertEqual(self.request('POST','/jobs',urlencode(dict(token='bad',customer='A',device='B')),True)[0],403)
  self.assertEqual(self.request('POST','/jobs',urlencode(dict(token=token,customer='<script>',device='Laptop')),True)[0],303)
  page=self.request('GET','/',auth=True)[1]; self.assertIn('&lt;script&gt;',page)
  self.assertEqual(self.request('POST','/status',urlencode(dict(token=token,id=1,status='Ready')),True)[0],303)
  self.assertIn('<option selected>Ready</option>',self.request('GET','/',auth=True)[1])
  self.assertEqual(self.request('POST','/status',urlencode(dict(token=token,id=1,status='invalid')),True)[0],400)
  self.assertEqual(self.request('POST','/jobs',urlencode(dict(token=token,customer='x'*101,device='Laptop')),True)[0],400)
  dest=Path(self.tmp.name)/'backup.sqlite'
  subprocess.run([sys.executable,str(Path(__file__).resolve().parents[1]/'scripts/snapshot.py'),str(Path(self.tmp.name)/'jobs.sqlite'),str(dest)],check=True)
  import sqlite3
  c=sqlite3.connect(dest)
  try: self.assertEqual(c.execute('SELECT status FROM jobs WHERE id=1').fetchone()[0],'Ready')
  finally: c.close()
  self.proc.terminate(); self.proc.wait()
  env=dict(os.environ,APP_PASSWORD='test-only-password',APP_PORT=str(self.port),DB_PATH=str(Path(self.tmp.name)/'jobs.sqlite'))
  type(self).proc=subprocess.Popen([sys.executable,str(Path(__file__).resolve().parents[1]/'app/server.py')],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
  for _ in range(50):
   try:
    if self.request('GET','/health')[0]==200: break
   except OSError: time.sleep(.1)
  else: self.fail('Restart failed')
  self.assertIn('&lt;script&gt;',self.request('GET','/',auth=True)[1])
if __name__=='__main__': unittest.main()
