# AI Imports
from tensorflow import float32, cast
from tensorflow.keras.models import Sequential, Model
from tensorflow.keras.preprocessing import image
from tensorflow.keras.layers import Dense, Dropout, Input, Lambda, Subtract, Flatten, Convolution2D, MaxPooling2D, ZeroPadding2D
from tensorflow.keras.optimizers import SGD, RMSprop, Adadelta
from tensorflow.keras import backend as K
from tensorflow.keras.regularizers import l2
from tensorflow.keras.callbacks import EarlyStopping
# Aditional imports
import numpy as np
import os
import math
import shutil
import requests
import random
from itertools import permutations, combinations

# Multiprocessing
from multiprocessing import Process, Lock, Manager

inputShape = (155, 200, 1)
modelserver_url = "http://127.0.0.1:6000/"

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

def signature_load_image(pid, images_to_fetch, sigs_pool, image_list, label_list, lock_sigs, lock_batch):
	#print("Process #", pid, "has to fetch: ", images_to_fetch, "images")
	for i in range(images_to_fetch):

		# Fetch 4 images, stop when there is none left
		lock_sigs.acquire()
		if len(sigs_pool) == 0:
		  lock_sigs.release()
		  break
		single_sig = sigs_pool.pop(0)
		lock_sigs.release()


		label = single_sig[2]

		# Paths to IMG
		path1 = single_sig[0]
		path2 = single_sig[1]

		# Fetch IMG
		img1 = preprocess_image(path1)
		img2 = preprocess_image(path2)

		# Add Image pair to the Image list and label to the Label List
		lock_batch.acquire()
		image_list += [img1[0], img2[0]]
		label_list += [label]
		lock_batch.release()

def SignatureGeneratorTV(pool, batchSize, num_fetch_threads):
	#k = 1
	copy_list = Manager().list(pool.copy())
	while True:
		processes = []
		images = Manager().list()
		labels = Manager().list()
		lock_batch = Lock()
		lock_sigs = Lock()

		# Create the N threads
		for i in range(num_fetch_threads):
			p = Process(target=signature_load_image,
				args=[i, (batchSize//num_fetch_threads), copy_list, images, labels, lock_sigs, lock_batch])
			p.start()
			processes.append(p)


		for process in processes:
			process.join()

		# Casting to List
		images = list(images)
		labels = list(labels)

		# Casting to Numpy Arrays
		images = [np.array(images)[:,0], np.array(images)[:,1]]
		labels = np.array(labels)

		# Refilling signatures list
		if len(copy_list) == 0:
		  copy_list = Manager().list(pool.copy())

		yield(images, labels)


def euclidean_distance(vects):
	x, y = vects
	return K.sqrt(K.sum(K.square(x - y), axis=1))


def eucl_dist_output_shape(shapes):
	shape1, shape2 = shapes
	return (shape1[0], 1)


def contrastive_loss(y_true, y_pred):
	'''Contrastive loss from Hadsell-et-al.'06
	http://yann.lecun.com/exdb/publis/pdf/hadsell-chopra-lecun-06.pdf
	tfa.losses.contrastive_loss
	'''
	margin = 1
	#print(type(y_true))
	#print(type(y_pred))
	y_pred = cast(y_pred, dtype=float32)
	y_true = cast(y_true, dtype=float32)
	return K.mean(y_true * K.square(y_pred) + (1 - y_true) * K.square(K.maximum(margin - y_pred, 0)))

def create_arch1(input_shape):
	
	seq = Sequential()
	seq.add(Convolution2D(96, kernel_size=11, strides=(4,4), activation='relu', name='conv1_1', input_shape= input_shape,
		kernel_initializer='glorot_uniform'))
	seq.add(MaxPooling2D((3,3), strides=(2, 2)))    
	seq.add(ZeroPadding2D((2, 2)))
	
	seq.add(Convolution2D(filters=256, kernel_size=5, strides=(1,1), activation='relu', name='conv2_1', kernel_initializer='glorot_uniform'))
	seq.add(MaxPooling2D((3,3), strides=(2, 2)))
	seq.add(Dropout(0.3))# added extra
	seq.add(ZeroPadding2D((1, 1)))
	
	seq.add(Convolution2D(filters=384, kernel_size=3, strides=(1,1), activation='relu', name='conv3_1', kernel_initializer='glorot_uniform'))
	seq.add(ZeroPadding2D((1, 1)))
	
	seq.add(Convolution2D(filters=256, kernel_size=3, strides=(1,1), activation='relu', name='conv3_2', kernel_initializer='glorot_uniform'))    
	seq.add(MaxPooling2D((3,3), strides=(2, 2)))
	seq.add(Dropout(0.3))# added extra
#    model.add(SpatialPyramidPooling([1, 2, 4]))
	seq.add(Flatten(name='flatten'))
	seq.add(Dense(1024, kernel_regularizer=l2(0.0005), activation='relu', kernel_initializer='glorot_uniform'))
	seq.add(Dropout(0.5))
	
	seq.add(Dense(128, kernel_regularizer=l2(0.0005), activation='relu', kernel_initializer='glorot_uniform')) # softmax changed to relu
	#seq.add(Dense(128, kernel_regularizer=l2(0.0005), activation='softmax', kernel_initializer='glorot_uniform')) # softmax changed to relu
	
	return seq


def generate_signer_pools(dir_path, n_signer, additional_i):
	# Get all Genuine and Forged Signatures from Signer
	# Genuine
	genuine_signs = os.listdir(dir_path + "/genuine")
	total_genuine = len(genuine_signs)

	#Forged
	forged_signs = os.listdir(dir_path + "/forged")
	total_forged = len(forged_signs)

	# Test pool (Percentage: 20%)
	test_pool_total_genuine = math.ceil(total_genuine*0.2)
	test_pool_genuine = np.random.choice(genuine_signs, test_pool_total_genuine, replace=False)

	test_pool_total_forged = math.ceil(total_forged*0.2)
	test_pool_forged = np.random.choice(forged_signs, test_pool_total_forged, replace=False)

	# Train pool (Percentage: 80%) and Validation pool (25% of the 80%)
	train_pool_total_genuine = total_genuine - test_pool_total_genuine
	train_pool_genuine = np.random.choice([x for x in genuine_signs if x not in test_pool_genuine], train_pool_total_genuine, replace=False)

	train_pool_total_forged = total_forged - test_pool_total_forged
	train_pool_forged = np.random.choice([x for x in forged_signs if x not in test_pool_forged], train_pool_total_forged, replace=False)

	# Validation pool
	validation_pool_total_genuine = math.ceil(train_pool_total_genuine * 0.25)
	validation_pool_genuine = np.random.choice(train_pool_genuine, validation_pool_total_genuine, replace=False)
	train_pool_genuine = [x for x in train_pool_genuine if x not in validation_pool_genuine]

	validation_pool_total_forged = math.ceil(train_pool_total_forged * 0.25)
	validation_pool_forged = np.random.choice(train_pool_forged, validation_pool_total_forged, replace=False)
	train_pool_forged = [x for x in train_pool_forged if x not in validation_pool_forged]

	# Real pools without labels
	test_pool = list(map(lambda x: dir_path + "/genuine/" + x, test_pool_genuine)) + list(map(lambda x: dir_path + "/forged/" + x, test_pool_forged))
	train_pool = list(map(lambda x: dir_path + "/genuine/" + x, train_pool_genuine)) + list(map(lambda x: dir_path + "/forged/" + x, train_pool_forged))
	validation_pool = list(map(lambda x: dir_path + "/genuine/" + x, validation_pool_genuine)) + list(map(lambda x: dir_path + "/forged/" + x, validation_pool_forged))

	# Generate combinations
	test_pool = list(combinations(test_pool, 2))
	train_pool = list(combinations(train_pool, 2))
	validation_pool = list(combinations(validation_pool, 2))

	# Generating labels
	test_pool = list(map(lambda x: [x[0], x[1], 0 if ("forged" in x[0]) or ("forged" in x[1]) else 1], test_pool))
	train_pool = list(map(lambda x: [x[0], x[1], 0 if ("forged" in x[0]) or ("forged" in x[1]) else 1], train_pool))
	validation_pool = list(map(lambda x: [x[0], x[1], 0 if ("forged" in x[0]) or ("forged" in x[1]) else 1], validation_pool))

	# Pair: [image_name, label]

	return train_pool, validation_pool, test_pool


def train_siamese(dir_path, signers):
	# Generate pool for train, validation and train
	train_pool, validation_pool, test_pool = [], [], []
	for i in range(len(signers)):
		temp_train_pool, temp_validation_pool, temp_test_pool = generate_signer_pools(dir_path + "/" + signers[i], i, 1)

		train_pool += temp_train_pool
		validation_pool += temp_validation_pool
		test_pool += temp_test_pool

	random.shuffle(train_pool)
	random.shuffle(validation_pool)
	random.shuffle(test_pool)

	# -------------------------------------------------------------

	# Creating Architecture
	base_network = create_arch1(inputShape)

	input_a = Input((inputShape))
	input_b = Input((inputShape))

	processed_a = base_network(input_a)
	processed_b = base_network(input_b)

	embedded_distance = Subtract(name='subtract_embeddings')([processed_a, processed_b])
	distance = Lambda(
			lambda x: K.sqrt(K.sum(K.square(x), axis=-1, keepdims=True)), name='euclidean_distance'
			)(embedded_distance)

	prediction = Dense(1, activation='sigmoid', kernel_initializer='glorot_uniform')(distance)

	model = Model([input_a, input_b],prediction)

	# compile model
	rms = RMSprop(lr=1e-4, rho=0.9, epsilon=1e-08)
	adadelta = Adadelta()
	model.compile(loss=contrastive_loss, optimizer=rms)

	# Train setup Variables
	epochs = 100
	batch_size = 64
	num_threads = 8
	samples_per_train = (len(train_pool))//batch_size + (1 if len(train_pool)%batch_size > 0 else 0)
	samples_per_validation = (len(validation_pool))//batch_size + (1 if len(validation_pool)%batch_size > 0 else 0)

	# Train Model
	
	estopping_callback = EarlyStopping(monitor='val_loss', patience=5, mode='auto',
		restore_best_weights=True, min_delta = 0.01)

	model.fit(
		x=SignatureGeneratorTV(train_pool, batch_size, num_threads),
		steps_per_epoch=samples_per_train,
		epochs=epochs,
		validation_data=SignatureGeneratorTV(validation_pool, batch_size, num_threads),
		validation_steps=samples_per_validation,
		verbose=0,
		callbacks = [estopping_callback]
	)


	# Saving Model
	filename = "siamese_model.h5"
	save_path = dir_path + "/" + filename
	model.save(filepath=save_path, overwrite=True, save_format='h5')
	

	try:
		filem = bytearray()
		with open(save_path, "rb") as file:
			while True:
				piece = file.read(4096)   # Read a word
				if piece == b'':
					break

				filem.extend(piece)
		server_response = requests.post(modelserver_url + 'store',
				json = {'typem': 3, "file": list(filem), "filename": filename}).json()
	except:
		pass
	finally:
		if os.path.exists(dir_path):
			shutil.rmtree(dir_path)