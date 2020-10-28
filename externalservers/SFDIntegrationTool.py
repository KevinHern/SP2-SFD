import io
import threading
import os
import time
import requests
from pathlib import Path

imgserver_url = "https://sp2imgserver.herokuapp.com/"
#imgserver_url = "http://127.0.0.1:5000/"

def upload_img(filepath, signer, typesig, imgname, sclient):
	sjson = {"project": "SP2-SFD-KH-17001095"}

	# Retreive Image
	img = bytearray()
	try:
		with open(filepath, "rb") as file:
			while True:
				piece = file.read(4096)   # Read a word
				if piece == b'':
					break

				img.extend(piece)

		sjson["signer"] = signer
		sjson["typesig"] = typesig
		sjson["imgname"] = imgname
		sjson["img"] = list(img)
		sjson["sclient"] = sclient

		# Uploading image
		server_response = requests.post(imgserver_url + 'storeimg', json = sjson).json()
		if(server_response['code'] == 1):
			print("Succesfully uploaded the following image: " + str(filepath).split('/')[-1])
		else:
			print("An error occurred while uploading the following image: " + str(filepath).split('/')[-1])
	except:
		print("An error occurred while uploading the following image: " + str(filepath).split('/')[-1])

def delete_img(signer, typesig, imgname, sclient):
	sjson = {"project": "SP2-SFD-KH-17001095"}

	# Delete Image
	try:

		sjson["signer"] = signer
		sjson["typesig"] = typesig
		sjson["imgname"] = imgname
		sjson["sclient"] = sclient

		# Uploading image
		server_response = requests.post(imgserver_url + 'deleteimg', json = sjson).json()
		if(server_response['code'] == 1):
			print("Succesfully deleted the following image: " + imgname)
		else:
			print("An error occurred while deleting the following image: " + imgname)
	except:
		print("An error occurred while deleting the following image: " + imgname)

def delete_user(signer, sclient):
	sjson = {"project": "SP2-SFD-KH-17001095"}

	# Delete User
	try:

		sjson["signer"] = signer
		sjson["sclient"] = sclient
		sjson["confirm"] = True

		# Uploading image
		server_response = requests.post(imgserver_url + 'deletesigner', json = sjson).json()
		if(server_response['code'] == 1):
			print("Succesfully deleted the user: " + signer)
		else:
			print("An error occurred while deleting the user: " + signer)
	except:
		print("An error occurred while deleting the user: " + signer)

def getUserType():
	user_option = input("\nIs the user a Client or Employee?:\n(1) Client\n(2) Employee\nYour Option: ")
	while str(user_option) != "1" and str(user_option) != "2":
		user_option = input("\nIs the user a Client or Employee?:\n(1) Client\n(2) Employee\nYour Option: ")
	user_option = int(user_option)
	return (True if user_option == 1 else False)

def upload_option():
	print("This is a tool for uploading a group of images for an existing or non existing user in the Firebase DB")

	# ------------------------------------------------

	# Choosing directory
	current_direcory = os.getcwd()
	print("\n// Directory Selection //")
	while True:
		print("\nYou are here: " + current_direcory + "\n")
		p = Path(current_direcory)
		subdirs = [str(f) for f in p.iterdir() if f.is_dir()]
		i = 0
		for dirfile in subdirs:
			print("(" + str(i+1) + ") " + dirfile)
			i += 1

		print("(" + str(i+1) + ") Current Directory")
		i += 1
		print("(" + str(i+1) + ") Previous Directory")
		i += 1
		option = input("Your option: ")

		try:
			dir_option = int(str(option))
			if dir_option == (i):
				# Previous directory
				os.chdir("../")
				current_direcory = os.getcwd()
			elif dir_option == (i-1):
				# Choosing this directory
				confirmation = input("Are you sure this is the correct directory? (y/n) ")
				while confirmation != 'y' and confirmation != 'n':
					confirmation = input("Are you sure this is the correct directory? (y/n) ")

				if confirmation == 'y':
					break
				else:
					continue
			else:
				# Choosing a subdirectory
				os.chdir(subdirs[dir_option-1])
				current_direcory = os.getcwd()

		except error:
			print("Unrecognized option")


	# Selecting files
	chosen_files = []
	while True:
		# Get files and filter them
		files_in_dir = list(filter(lambda x: (".jpeg" in x) or (".jpg" in x) or (".png" in x),
			os.listdir(current_direcory)))
		candidate_files = [x for x in files_in_dir if x not in chosen_files]

		# List candidate files
		print("\nFiles available: ")
		i = 0
		for candidate in candidate_files:
			print("(" + str(i+1) + ") " + candidate)
			i += 1

		print("(" + str(i+1) + ") Add all")
		i += 1
		print("(" + str(i+1) + ") Done")
		i += 1

		option = input("Your option: ")
		# Getting selected file
		try:
			option = int(option)
			if option == (i):
				# Done
				break
			if option == (i-1):
				chosen_files += candidate_files
				break
			else:
				# Keep choosing files, add candidate file
				chosen_files += [candidate_files[option-1]]
		except:
			print("Unrecognized option")

	# Genuine or Forged
	genfor_upload = input("\nAre these signatures genuine or forged?:\n(1) Genuine signature(s)\n(2) Forged signature(s)\nYour Option: ")
	while str(genfor_upload) != "1" and str(genfor_upload) != "2":
		genfor_upload = input("\nAre these signatures genuine or forged?:\n(1) Genuine signature(s)\n(2) Forged signature(s)\nYour Option: ")
	genfor_upload = int(genfor_upload)
	genfor_upload = 1 if genfor_upload == 1 else 0

	# ---------------------------------------------

	# Existing user or not
	existing_user = input("\nChoose one of the following options:\n(1) User exists\n(2) User does not exist\nYour Option: ")
	while str(existing_user) != "1" and str(existing_user) != "2":
		existing_user = input("\nChoose one of the following options:\n(1) User exists\n(2) User does not exist\nYour Option: ")
	existing_user = int(existing_user)

	# Client or employee
	user_option = getUserType()


	if existing_user == 1:
		# User exists

		# Listing existing users
		server_response = requests.post(imgserver_url + 'signers', json = {'sclient': user_option}).json()

		user_name = ""
		can_upload = True
		while True:
			i = 0
			print("\nExisting " + ("clients" if user_option else "employees") + ": ")

			# Validate that users do exists
			try:
				if len(server_response['signers']) == 0:
					pass
			except:
				print("No " + ("clients" if user_option else "employees") + " exist. Aborting operation\n")
				can_upload = False
				break

			# Listing existing users
			for euser in server_response['signers']:
				print("(" + str(i+1) + ") " + euser)
				i += 1

			print("or\n(" + str(i+1) + ") Abort operation")
			i += 1

			# Choosing user
			try:
				option = int(input("Your option: "))

				if option == i:
					print("Aborting operation.")
					can_upload = False
				else:
					# Confirmation
					confirmation = input("Is this the correct codename? (y/n) ")
					while confirmation != 'y' and confirmation != 'n':
						confirmation = input("Is this the correct codename? (y/n) ")

					if confirmation == 'y':
						user_name = server_response['signers'][option-1]
						break
					else:
						continue
			except:
				print("Unrecognized option")

		# Uploading
		if can_upload:
			# Upload images
			for sigimage in chosen_files:
				upload_img(current_direcory + "/" + sigimage, user_name, genfor_upload, sigimage, user_option)

	else:
		# User does not exist
		user_name = input("Provide the codename for the new user: ")
		while True:
			confirmation = input("Is this the correct codename? (y/n) ")
			while confirmation != 'y' and confirmation != 'n':
				confirmation = input("Is this the correct codename? (y/n) ")

			if confirmation == 'y':
				break
			else:
				user_name = input("Provide the codename for the new user: ")

		# Upload images
		confirmation = input("Upload the images? (y/n) ")
		while confirmation != 'y' and confirmation != 'n':
			confirmation = input("Upload the images? (y/n) ")

		if confirmation == 'y':
			for sigimage in chosen_files:
				upload_img(current_direcory + "/" + sigimage, user_name, genfor_upload, sigimage, user_option)
		else:
			print("You decided to not upload the images.")

	print("\nUpload done")


def delete_option():
	print("This is a tool for deleting a group of images for an existing")

	# -----------------------------------------

	# Choose type of user: Client or Employee
	sclient = getUserType()

	# Choosing signer: listing existing users
	server_response = requests.post(imgserver_url + 'signers', json = {'sclient': sclient}).json()

	user_name = ""
	while True:
		i = 0
		print("\nExisting " + ("clients" if sclient else "employees") + ": ")

		if len(server_response['signers']) == 0:
			break

		for euser in server_response['signers']:
			print("(" + str(i+1) + ") " + euser)
			i += 1
		
		option = int(input("Your option: "))

		# Confirmation
		confirmation = input("Is this the correct codename? (y/n) ")
		while confirmation != 'y' and confirmation != 'n':
			confirmation = input("Is this the correct codename? (y/n) ")

		if confirmation == 'y':
			user_name = server_response['signers'][option-1]
			break
		else:
			continue

	# Choose type of images
	action_option = input("\nAre you going to delete genuine, forged signatures or the user?:\n(1) Genuine signature(s)\n(2) Forged signature(s)\n(3) User\nYour Option: ")
	while str(action_option) != "1" and str(action_option) != "2" and str(action_option) != "3":
		action_option = input("\nAre you going to delete genuine, forged signatures or the user?:\n(1) Genuine signature(s)\n(2) Forged signature(s)\n(3) User\nYour Option: ")
	action_option = int(action_option)

	# Option
	if action_option == 3:
		# Deleting user
		try:
			# Confirmation
			confirmation = input("Are you sure you want to delete this user? (y/n) ")
			while confirmation != 'y' and confirmation != 'n':
				confirmation = input("Are you sure you want to delete this user? (y/n) ")

			if confirmation == 'y':
				delete_user(user_name, sclient)
			else:
				print("Operation aborted")
		except:
			print("Unrecognized option")
	else:
		# Get images
		typesig = 1 if action_option == 1 else 0
		server_response = requests.post(imgserver_url + 'signames', json = {'signer': user_name, 'typesig': typesig, 'sclient': sclient}).json()

		chosen_files = []
		while True:
			candidate_files = [x for x in server_response['filenames'] if x not in chosen_files]
			i = 0

			for sigfile in candidate_files:
				print("(" + str(i+1) + ") " + sigfile)
				i += 1

			print("(" + str(i+1) + ") Add all")
			i += 1
			print("(" + str(i+1) + ") Undo")
			i += 1
			print("(" + str(i+1) + ") Done")
			i += 1

			option = input("Your option: ")
			# Getting selected file
			try:
				option = int(option)
				if option == (i):
					# Done
					break
				elif option == (i-1):
					# Undo
					chosen_files.pop(-1)
				elif option == (i-2):
					# Undo
					chosen_files += candidate_files
				else:
					# Keep choosing files, add candidate file
					chosen_files += [candidate_files[option-1]]
			except:
				print("Unrecognized option")

		# Deleting images
		try:
			# Confirmation
			confirmation = input("Are you sure you want to delete these images? (y/n) ")
			while confirmation != 'y' and confirmation != 'n':
				confirmation = input("Are you sure you want to delete these images? (y/n) ")

			if confirmation == 'y':
				for sigfile in chosen_files:
					delete_img(user_name, typesig, sigfile, sclient)
			else:
				print("Operation aborted")
		except:
			print("Unrecognized option")



def main():
	print("// SP2-KH-17001095 //\n")
	options = ["Upload Images", "Delete Images/User", "Exit"]
	while True:
		try:
			i = 0
			for option in options:
				print("(" + str(i+1) + ") " + option)
				i += 1

			option = int(input("Your option: "))

			if option == 1:
				upload_option()
			elif option == 2:
				delete_option()
			elif option == i:
				break
			else:
				print("Unrecognized option")	
		except:
			break

main()