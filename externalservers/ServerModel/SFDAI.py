import tensorflow as tf
import os
from tensorflow.keras.preprocessing import image
import numpy as np
import requests
import random

imgserver_url = "https://sp2imgserver.herokuapp.com/"

def preprocess_image(image_path):
	# Loads image in grayscale and rescaled
    img = image.load_img(image_path, target_size = (155, 200), color_mode="grayscale")

    # Convert to array
    img = image.img_to_array(img)

    # Invert White and Black
    img = 255 - img

    # Apply Threshold: All pixels below 50 become fully black while the others are converted to fully white
    img = ((img//50) + 5)//6

    # Save modified image
    image.save_img(path=image_path, x= img, scale=True, data_format='channels_last')

    # Reload again
    img = image.load_img(image_path, target_size = (155, 200), color_mode="grayscale")
    img = image.img_to_array(img)
    return [img]



def conv_model_predict(proc_img, signer, sclient):
	# Paths
	path = "Models/ConvModel/" + ("client/" if sclient else "employee/")

	# Read signers to get the classes
	classes = []
	with open(path + "classes.txt") as file_classes: 
		while True: 
			line = file_classes.readline() 
			if not line: 
				break

			classes = line.split(",")
	 
	# Predict
	conv_model = tf.keras.models.load_model(path + "conv_model.h5")

	# Image Preprocessing
	img = [np.array(proc_img)]

	# Actual prediction
	probabilities = conv_model.predict(
		x=img,
		verbose=1
	)
	prediction = np.argmax(probabilities)
	pred_prob = probabilities[0][prediction]


	# Checking if it choose the correct signer
	sindex = classes.index(signer)

	if prediction == (2*sindex):
		return ["genuine", "correct", pred_prob]
	elif prediction == (2*sindex + 1):
		return ["forged", "correct", pred_prob]
	else:
		return ["forged", "incorrect"]
	

def signer_signature_model_predict(proc_img, signer, sclient):
	path = "Models/SSModel/" + ("client/" if sclient else "employee/")
	answer = []
	
	# Read signers to get the classes
	classes = []
	with open(path + "classes.txt") as file_classes: 
		while True: 
			line = file_classes.readline() 
			if not line: 
				break

			classes = line.split(",")

	# Image Preprocessing
	img = [np.array(proc_img)]
	 
	# Predict Signer
	signer_model = tf.keras.models.load_model(path + "signer_model.h5")
	signer_p = signer_model.predict(
		x=img,
		verbose=1
	)
	signer_p = np.argmax(signer_p)
	

	# Checking if it choose the correct signer
	sindex = classes.index(signer)
	#print("Signer_p value:" + str(signer_p) + "\tsindex value: " + str(sindex) + "\tindex value: " + str(signer))

	if signer_p == sindex:
		answer += ["correct"]
	else:
		answer += ["incorrect"]

	# Checking the veracity of the signature
	# 0 = Forged, 1 = Genuine
	signature_model = tf.keras.models.load_model(path + "signatures/signature_model_" + str(signer) + ".h5")
	prediction = signature_model.predict(
		x=img,
		verbose=1
	)
	veredict = "genuine" if prediction >= 0.5 else "forged" 
	answer = [veredict] + answer + [prediction[0][0] if veredict == 'genuine' else (1-prediction[0][0])]
	return answer

def siamese_model_predict(proc_img, signer, sclient, worker):
	path = "Models/SiameseModel/" + ("client/" if sclient else "employee/")
	answer = []
	
	try:
		# Getting a pivot image
		server_response = requests.post(imgserver_url + 'signames', json = {'signer': str(signer), 'typesig': 1, 'sclient': sclient}).json()

		# Selecting random image
		pivot_name = random.choice(server_response['filenames'])

		# Get the image
		img_response = requests.post(imgserver_url + '/retreiveimg', json = {'signer': str(signer), 'typesig': 1, 'imgname': pivot_name, 'sclient': sclient}).json()

		# Sanity check
		pivot_path = './temp/' + worker + "-" + pivot_name
		if img_response["exists"]:
			# Convert image to byte array
			img_bytes = bytearray(img_response["img"])

			# Saving it temporaly
			file = open(pivot_path, "wb")
			file.write(img_bytes)
			file.close()
		else:
			raise Exception("not good")

		# Image Preprocessing
		proc_pivot = preprocess_image(pivot_path)

		
		pair = [np.array(proc_pivot), np.array(proc_img)]

		# Below 0.5 is Genuine, above 0.5 is Forged
		#print(path)
		siamese_model = tf.keras.models.load_model(path + "siamese_model.h5")
		'''
		prediction = siamese_model.predict(
			x=pair,
			verbose=1
		)
		'''

		prediction = 0
		answer = [1]
		answer += ["genuine" if prediction <= 0.5 else "forged"]
	except Exception as e:
		print("////////////")
		print(e)
		answer = [0]

	
	return answer