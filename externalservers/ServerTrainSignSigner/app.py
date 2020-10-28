from flask import Flask, request, jsonify
import SFDSS as ai
import io
import threading
import os
import time
import requests
from multiprocessing import Process

imgserver_url = "https://sp2imgserver.herokuapp.com/"

def worker():
	return threading.current_thread().name + str(threading.get_ident())

def get_images(signer, typesig, dir_name, sclient):
	type_dir = "/genuine/" if typesig == 1 else "/forged/"

	# Getting Images
	sresponse = requests.post(imgserver_url + '/signames',
		json = {'signer': signer, 'typesig': typesig, 'sclient': sclient}).json()
	for sign_name in sresponse["filenames"]:
		# Make a request to get the img from the IMG server
		img_response = requests.post(imgserver_url + '/retreiveimg',
			json = {'signer': signer, 'typesig': typesig, 'imgname': sign_name, 'sclient': sclient}).json()

		# Sanity check
		if img_response["exists"]:
			# Convert image to byte array
			img_bytes = bytearray(img_response["img"])

			# Saving it temporaly
			file = open(dir_name + type_dir + sign_name, "wb")
			file.write(img_bytes)
			file.close()

			ai.preprocess_image(dir_name + type_dir + sign_name)
		else:
			continue

# create the flask object
app = Flask(__name__)

@app.route('/')
def index():
	return "You should not be here"

@app.route('/train',methods=['POST'])
def train():
	# Get JSON
	rjson = request.get_json()

	'''
	Fields:
	- typem: "Type Model", (0) if Signer model or (1) Signature model
	- signers (array): only comes when typem = 0
	- signer (single field): only comes typem = 1

	Output: server_response
	- Project Authory
	'''

	# Extracting model
	typem = rjson['typem']
	sclient = rjson['sclient']


	# Dispatching request
	server_response = {"project": "SP2-SFD-KH-17001095"}
	filepath = ""

	# DIR paths to delete later
	dir_name = "./temp/" + worker()

	# Train Conv Signer model
	if typem == 21:
		# Getting Images
		sresponse = requests.post(imgserver_url + '/signers', json = {'sclient': sclient}).json()
		for signer in sresponse["signers"]:
			# Genuine and Forged directory
			if not os.path.exists(dir_name + "/" + signer + "/genuine"):
				os.makedirs(dir_name + "/" + signer + "/genuine")
			if not os.path.exists(dir_name + "/" + signer + "/forged"):
				os.makedirs(dir_name + "/" + signer + "/forged")

			# Getting Genuine Images
			get_images(signer, 1, dir_name + "/" + signer, sclient)
				
			# Getting Forged Images
			get_images(signer, 0, dir_name + "/" + signer, sclient)

		# Train Model
		# ai.train_signer(dir_name, sresponse["signers"], sclient)
		process = Process(target=ai.train_signer, args=[dir_name, sresponse["signers"], sclient])
		process.start()

	# Train signature conv model
	else:
		signer = rjson["signer"]

		# Genuine and Forged directory
		if not os.path.exists(dir_name + "/genuine"):
			os.makedirs(dir_name + "/genuine")
		if not os.path.exists(dir_name + "/forged"):
			os.makedirs(dir_name + "/forged")

		# Getting Genuine Images
		get_images(signer, 1, dir_name, sclient)
			
		# Getting Forged Images
		get_images(signer, 0, dir_name, sclient)

		# Train Model
		#ai.train_signature(dir_name, signer, sclient)
		process = Process(target=ai.train_signature, args=[dir_name, signer, sclient])
		process.start()

	server_response["code"] = 1
	# Return in JSON
	return jsonify(server_response)

if __name__ == "__main__":
	app.run(host='127.0.0.1',port=5002, debug=True)