#!/usr/bin/env python
import os
import sys
import json
import fnmatch
import glob
from flask import Flask, g, url_for
from flask import render_template, request
import argparse
import re

parser = argparse.ArgumentParser()
parser.add_argument('-d', '--dir', default="", type=str, help="Path of image directory.")
parser.add_argument('-p', '--port', default="8000", type=int, help="Port.")
parser.add_argument('-s', '--search', default=None, type=str, help="Image contains this (these) string(s).")
parser.add_argument('-f', '--file', default=None, type=str, help="File containing a list of images to pull.") 
args = parser.parse_args()
image_dir = os.path.abspath(args.dir)
port = args.port
terms = args.search
imagefile = args.file
if terms is not None:
        searchlist = re.compile(terms)
if imagefile is not None:
	with open(imagefile) as f:
		terms = f.read().splitlines()
		searchlist = r'|'.join(terms)
		print searchlist
		searchlist = re.compile(searchlist)
app = Flask(__name__, 
            static_url_path = '', 
            static_folder = image_dir)
app.debug = True

@app.route("/")
def index():
    types = ["*.png", "*.jpg", "*.JPG"]
    image_list = []
    for cur_type in types:
        image_list.extend(glob.glob(os.path.join(image_dir, cur_type)))
	try:
		image_list = [url_for("static", filename=os.path.basename(x)) for x in image_list if re.search(searchlist,x)]
	except:
		image_list = [url_for("static", filename=os.path.basename(x)) for x in image_list]
    return render_template("index.html", image_list = image_list)
app.run(host='10.96.148.16', port=port, threaded=True) 

