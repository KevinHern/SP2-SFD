import tensorflow as tf
import os
from tensorflow.keras.preprocessing import image
import numpy as np

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



def conv_model_predict(image_path, signer, sclient):
	# Paths
	path = "Models/ConvModel/" + ("client" if sclient else "employee")

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
	img = [np.array(preprocess_image("./temp/" + image_path))]

	# Actual prediction
	prediction = conv_model.predict(
		x=img,
		verbose=1
	)
	prediction = np.argmax(prediction)



	# Checking if it choose the correct signer
	sindex = classes.index(signer)

	if prediction == (2*sindex):
		return ["genuine", "correct"]
	elif prediction == (2*sindex + 1):
		return ["forged", "correct"]
	else:
		return ["forged", "incorrect"]
	

def signer_signature_model_predict(image_path, signer, sclient):
	path = "Models/SSModel/" + ("client" if sclient else "employee")
	answer = []
	
	# Read signers to get the classes
	classes = []
	with open(path + "classes.txt") as file_classes: 
		while True: 
			count += 1
			line = file_classes.readline() 
			if not line: 
				break

			classes = line.split(",")

	# Image Preprocessing
	img = [np.array(preprocess_image("./temp/" + image_path))]
	 
	# Predict Signer
	signer_model = tf.keras.models.load_model(path + "signer_model.h5")
	signer_p = signer_model.predict(
		x=img,
		verbose=1
	)
	signer_p = np.argmax(signer_p)

	# Checking if it choose the correct signer
	sindex = classes.index(signer)

	if signer_p == sindex:
		answer += ["correct"]
	else:
		answer += ["incorrect"]

	# Checking the veracity of the signature
	# 0 = Forged, 1 = Genuine
	signature_model = tf.keras.models.load_model(path + "Signatures/signature_model_" + str(signer) + ".h5")
	prediction = signature_model.predict(
		x=img,
		verbose=1
	)
	
	answer = ["genuine" if prediction >= 0.5 else "forged"] + answer

	return answer

def siamese_model_predict(image_path, pivot_path, sclient):
	path = "Models/SiameseModel/" + ("client" if sclient else "employee")

	# Image Preprocessing
	pair = [np.array(preprocess_image("./temp/" + pivot_path)), np.array(preprocess_image("./temp/" + image_path))]

	# Below 0.5 is Genuine, above 0.5 is Forged
	siamese_model = tf.keras.models.load_model(path + "Signatures/siamese_model.h5")
	prediction = siamese_model.predict(
		x=pair,
		verbose=1
	)
	
	return "genuine" if prediction <= 0.5 else "forged"