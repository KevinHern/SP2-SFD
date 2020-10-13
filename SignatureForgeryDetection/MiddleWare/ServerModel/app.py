from flask import Flask, request, jsonify
import SFDAI as ai
import io
import threading
import os
import time
import requests

cnv_server = "http://127.0.0.1:5001/"
ss_server = "http://127.0.0.1:5002/"
sms_server = "http://127.0.0.1:5003/"


def worker():
    return threading.current_thread().name + str(threading.get_ident())

# create the flask object
app = Flask(__name__)

@app.route('/')
def index():
	return "You should not be here"

@app.route('/store', methods=['POST'])
def store():
	# Get JSON
	rjson = request.get_json()

	'''
	Fields:
	- typem: Type of model that is going to be stored. (1: conv, 21: ss-signer, 22: ss-signature, 3: siamese)
	- file (array of bytes): actual file
	- filename: self explanatory.
	- signer: only comes when typem = ss-signature
	- classes: only comes when typem = ss-signer or conv

	Output:
	- Project Authory
	- code: 1 if successful or 0 otherwise
	'''

	server_response = {"project": "SP2-SFD-KH-17001095"}

	# Extracting type of model
	typem = rjson['typem']
	file_bytes = bytearray(rjson["file"])
	filename = rjson["filename"]
	sclient = rjson['sclient']

	dir_path = ""
	aux_path = ""
	if typem == 1:
		dir_path = "Models/ConvModel"
	elif typem == 21:
		dir_path = "Models/SSModel"

		str_to_save = ""
		for signer_class in rjson["classes"]:
			str_to_save += str(signer_class) + ","

		# Save Classes
		file1 = open(dir_path + "/" + "classes.txt","w")
		file1.write(str_to_save) 
		file1.close() 
	elif typem == 22:
		dir_path = "Models/SSModel/"
		aux_path = "/signatures"
	elif typem == 3:
		dir_path = "Models/SiameseModel"
	else:
		server_response["code"] = 1

	# Creating Directory if it does not exist

	dir_path += "/client" if sclient else "/employee" + aux_path
	if not os.path.exists(dir_path):
		os.makedirs(dir_path)

	# Saving file
	file = open(dir_path + "/" + filename, "wb")
	file.write(file_bytes)
	file.close()
	return jsonify(server_response)

@app.route('/predict',methods=['POST'])
def predict():
	# Get JSON
	rjson = request.get_json()

	'''
	Fields:
	- models: says how many and what models are going to predict. Expected order: conv_model (1), ss_model (2), siamese_model (3)
	- sclient (bool): True if it is a client signature
	- signer: only comes when predicting with ss_model
	- img: (array of bytes) image encoded.
	- imgext: image's extension
	- pivotsign: image to use for comparison. Only useful if siamese_model is used
	- pivotext: pivot's extension

	Output:
	- Project Authory
	'''

	# Extracting what models are going to predict
	models = rjson['models']

	# Extracting Image and convert it to an array of bytes
	img = rjson['img']
	imgext = rjson['imgext']
	img_bytes = bytearray(img)
	filename = worker() + "." + imgext

	# Saving it temporaly
	file = open("./temp/" + filename, "wb")
	file.write(img_bytes)
	file.close()

	sclient = rjson['sclient']

	predictions = {"project": "SP2-SFD-KH-17001095"}
	#models = []
	# Predicting with Conv Model
	if 1 in models:
		# Extracting signer
		signer = str(rjson['signer'])

		# Prediction results
		results_cm = ai.conv_model_predict(filename, signer, sclient)
		dict_cm = {"prediction": results_cm[0], "signerp": results_cm[1]}
		predictions["conv_model"] = dict_cm

	# Predicting with SS Model
	if 2 in models:
		# Extracting signer
		signer = str(rjson['signer'])

		# Prediction results
		results_ssm = ai.signer_signature_model_predict(filename, signer, sclient)
		dict_ssm = {"prediction": results_ssm[0], "signerp": results_ssm[1]}
		predictions["ss_model"] = dict_ssm

	# Predicting with Siamese Model
	if 3 in models:
		# Extracting pivot image
		pivot = rjson['pivot']
		pivotext = rjson['pivotext']
		pivot_bytes = bytearray(pivot)
		pivot_filename = worker() + "." + pivotext

		# Saving it temporaly
		file = open("./temp/" + pivot_filename, "wb")
		file.write(pivot_bytes)
		file.close()
		
		# Prediction results
		results_sm = ai.siamese_model_predict(filename, pivot_filename, sclient)
		dict_sm = {"prediction": results_sm}
		predictions["siamese_model"] = dict_sm

		# Deleting Pivot Image
		#if os.path.exists("./temp/" + pivot_filename):
		#	os.remove("./temp/" + pivot_filename)

	# Deleting File after its usage
	#if os.path.exists("./temp/" + filename):
	#	os.remove("./temp/" + filename)

	# Return in JSON
	return jsonify(predictions)

@app.route('/train',methods=['POST'])
def train():
	rjson = request.get_json()
	'''
	Fields:
	- typem (int): 1 (convolutional), 21 (signer), 22 (signature) or 3 (siamese)
	- sclient (bool) True if client or false if not

	Output:
	- Project Authory
	'''

	# Extracting fields
	typem = rjson['typem']
	sclient = rjson['sclient']

	# Sending signal to train
	server_response = {"project": "SP2-SFD-KH-17001095"}

	server_url = ""

	train_json = {'typem': typem, "sclient": sclient, "confirm": True}

	if typem == 1:
		server_url = cnv_server
	elif typem == 21:
		server_url = ss_server
	elif typem == 22:
		server_url = ss_server
		train_json["signer"] = rjson['signer']
	elif typem == 3:
		server_url = sms_server
	else:
		server_url = ""
		train_json["confirm"] = False
	
	if len(server_url) > 0:
		server_response = requests.post(server_url + 'train',
				json = train_json).json()

	return jsonify(server_response)


@app.route('/info',methods=['POST'])
def info():
	server_response = {"project": "SP2-SFD-KH-17001095"}

	# Get JSON
	rjson = request.get_json()

	'''
	Fields:
	- typem: 1 for CNV, 21 for SIGNER and 3 for SIAMESE
	- sclient: True is Client else False
	- signer (string): only comes when typem = 22

	Output:
	- exists (bool): self explanatory
	- lastdate: date of creation
	- signers (array): group of signers used to train the model (only appears when typem = 1 or type = 21)
	'''

	# Extracting fields:
	typem = rjson['typem']
	sclient = rjson['sclient']

	if typem == 1:
		model_path = "./Models/ConvModel" + ("/client" if sclient else "/employee")
		try:
			server_response['exists'] = True

			cdate = str(time.ctime(os.path.getctime(model_path + "/conv_model.h5"))).split(' ')

			server_response['lastdate'] = cdate[1] + " " + cdate[3] + " " + cdate[-1] + " at " + cdate[4]

			# Getting signers
			classes = []
			with open(model_path + "/classes.txt") as file_classes: 
				while True: 
					line = file_classes.readline() 
					if not line: 
						break

					classes = line.split(",")
					classes.pop(-1)
			server_response['signers'] = classes
		except:
			server_response['exists'] = False
	elif typem == 21:
		model_path = "./Models/SSModel" + ("/client" if sclient else "/employee")
		try:
			server_response['exists'] = True

			cdate = str(time.ctime(os.path.getctime(model_path + "/signer_model.h5"))).split(' ')

			server_response['lastdate'] = cdate[1] + " " + cdate[3] + " " + cdate[-1] + " at " + cdate[4]

			# Getting signers
			classes = []
			with open(model_path + "/classes.txt") as file_classes: 
				while True: 
					line = file_classes.readline() 
					if not line: 
						break

					classes = line.split(",")
					classes.pop(-1)
			server_response['signers'] = classes
		except:
			server_response['exists'] = False
	elif typem == 22:
		model_path = "./Models/SSModel" + ("/client/signatures/" if sclient else "/employee/signatures/")
		model_path += "signature_model_" + rjson['signer'] + ".h5"
		try:
			server_response['exists'] = True

			cdate = str(time.ctime(os.path.getctime(model_path))).split(' ')

			server_response['lastdate'] = cdate[1] + " " + cdate[3] + " " + cdate[-1] + " at " + cdate[4]
		except:
			server_response['exists'] = False
	elif typem == 3:
		model_path = "./Models/SiameseModel" + ("/client/" if sclient else "/employee/") + "siamese_model.h5"
		try:
			server_response['exists'] = True

			cdate = str(time.ctime(os.path.getctime(model_path))).split(' ')
			server_response['lastdate'] = cdate[1] + " " + cdate[3] + " " + cdate[-1] + " at " + cdate[4]

			# Getting signers
			classes = []
			with open(model_path + "/classes.txt") as file_classes: 
				while True: 
					line = file_classes.readline() 
					if not line: 
						break

					classes = line.split(",")
					classes.pop(-1)
			server_response['signers'] = classes
		except:
			server_response['exists'] = False
	else:
		server_response['exists'] = False

	return jsonify(server_response)


if __name__ == "__main__":
	app.run(host='127.0.0.1', port=6000, debug=True)