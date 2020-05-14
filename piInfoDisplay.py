#!/usr/bin/python3
import tkinter as tk
import tkinter.font as tkfont
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse
import html
import os

from io import BytesIO

textHandler=None
run_loop = True

class FullScreenApp(object):
	def __init__(self, master, **kwargs):
		self.master=master
		self.pad=3
		#self._geom='200x200+0+0'
		master.geometry("{0}x{1}+0+0".format(
			master.winfo_screenwidth()-self.pad, master.winfo_screenheight()-self.pad))
		# master.bind('<Escape>',self.toggle_geom)
		master.bind('<Escape>',self.quit_program)
		self.text=None
		self.canvas = tk.Canvas(self.master, width=self.master.winfo_screenwidth()-self.pad, height=self.master.winfo_screenheight()-self.pad, bg = '#000000')
		self.canvas.pack()
		self.font = tkfont.Font(family="Times", size=20, weight="bold")

	def toggle_geom(self,event):
		geom=self.master.winfo_geometry()
		print(geom,self._geom)
		self.master.geometry(self._geom)
		self._geom=geom
		
	def quit_program(self,event):
		global run_loop
		run_loop= False
		self.master.destroy()
	
	def draw_text(self,text,color,font_size=20):
		self.font.configure(size=font_size)
		x_size=self.master.winfo_screenwidth()-self.pad
		y_size=self.master.winfo_screenheight()-self.pad
		longest_text_len = 0
		text_elements=text.split("\n")
		for i in range(len(text_elements)):
			if text_elements[i][:1]=="&":
				text_elements[i]=text_elements[i][1:][::-1]
		for line in text_elements:
			text_len_pixel = self.font.measure(line)
			if text_len_pixel > longest_text_len:
				longest_text_len = text_len_pixel
		rtl_text="\n".join(text_elements)
		#text_len_pixel = self.font.measure(text)
		text_height_pixel=self.font.metrics('linespace')
		#x_pos=(x_size-longest_text_len)//2
		x_pos=(x_size)//2
		y_pos=(y_size-text_height_pixel)//2
		if self.text:
			self.canvas.delete(self.text)
		self.canvas.configure(bg=color)
		self.text = self.canvas.create_text( x_pos, y_pos, fill='black', font=self.font, text=rtl_text, justify='center')



class tkThread(object):
	""" Threading example class
	The run() method will be started and it will run in the background
	until the application exits.
	"""

	def __init__(self, interval=1):
		""" Constructor
		:type interval: int
		:param interval: Check interval, in seconds
		"""
		self.interval = interval

		thread = threading.Thread(target=self.run, args=())
		thread.daemon = True							# Daemonize thread
		thread.start()								  # Start the execution

	def run(self):
		global textHandler
		""" Method that runs forever """
		self.root=tk.Tk()
		self.app=FullScreenApp(self.root)
		textHandler=self.app
		#self.app.draw_text("moin",'red')
		self.root.mainloop()

	def quit(self):
		self.root.destroy()
		
class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):

	def do_GET(self):
		self.send_page(self.path)

	def do_POST(self):
		content_length = int(self.headers['Content-Length'])
		body = self.rfile.read(content_length)
		self.send_page('index.html')
		params=urllib.parse.parse_qs(body.decode())
		print(params)
		text=html.unescape(urllib.parse.unquote_plus(params['text'][0])).replace("\r","")
		color=params['color'][0]
		fontsize=int(params['fontsize'][0])
		global textHandler
		""" Method that runs forever """
		if textHandler:
			textHandler.draw_text(text,color,fontsize)

	def send_page(self,file_name):
		try:
			scriptpath = os.path.dirname(os.path.realpath(__file__))
			if file_name=="" or file_name=='/':
				file_name='index.html'
			with open(scriptpath + os.sep + file_name,'r') as f:
				if file_name.endswith(".html"): 
					content_type= "text/html"
				elif file_name.endswith(".js"): 
					content_type= "application/javascript"
				else:
					content_type= "application/octet-stream"
				content=f.read().encode()
				self.send_response(200)
				self.send_header("Content-type", content_type) 
				self.end_headers()
				self.wfile.write(content)
		except:
			self.send_response(404)
			self.send_header("Content-type", "text/html") 
			self.end_headers()
			
		


class webServerThread(object):
	""" Threading example class
	The run() method will be started and it will run in the background
	until the application exits.
	"""

	def __init__(self, interval=1):
		""" Constructor
		:type interval: int
		:param interval: Check interval, in seconds
		"""
		self.interval = interval

		thread = threading.Thread(target=self.run, args=())
		thread.daemon = True							# Daemonize thread
		thread.start()								  # Start the execution

	def run(self):
		global textHandler
		""" Method that runs forever """
		httpd = HTTPServer(('0.0.0.0', 8000), SimpleHTTPRequestHandler)
		if textHandler:
			textHandler.draw_text("Gehe auf\nWLAN: ipInfoDisplay\nPasswort: kindergarten\nUnd dann auf die Website\nhttp://192.168.48.1:8000",'lightblue')
		httpd.serve_forever()

	def quit(self):
		self.root.destroy()

tkthread = tkThread()
# wait a moment for the window to open before write something
time.sleep(3)
webthread = webServerThread()

while run_loop:
	time.sleep(1)
print('Bye')
