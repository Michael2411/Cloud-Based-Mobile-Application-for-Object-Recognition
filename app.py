from distutils.log import debug
from sys import stdout
# from makeup_artist import Makeup_artist
import logging
from xmlrpc import client
from flask import Flask, render_template, request ,flash ,redirect,send_file,jsonify
from flask_socketio import SocketIO, emit
# from camera import Camera
import base64
from imageio import imread
import numpy as np
import cv2
from werkzeug.utils import secure_filename
import os
import io
from yolov5_class import Yolo
from PIL import Image
import random
import json
import threading
import glob



#notes
"""
-mobile:
"""
parent_dir = os.getcwd()
def check_folder_create(folder_path):
    if not(os.path.isdir(folder_path)):
        path = os.path.join(parent_dir, folder_path) 
        os.makedirs(path) 

UPLOAD_FOLDER = 'uploads'
check_folder_create(UPLOAD_FOLDER)
check_folder_create("out_google_search")
check_folder_create("out_img")

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
app = Flask(__name__)
app.logger.addHandler(logging.StreamHandler(stdout))
app.config['SECRET_KEY'] = 'njkbhjvbgkcvgfchgcfcxfff5drtd56e567878ggf6767t6'
app.config['DEBUG'] = True
socketio = SocketIO(app, cors_allowed_origins="*" )
domain='https://ea7a-102-44-61-36.ngrok.io'


#####################################################################
#loading the model for one time
model = Yolo()
#####################################################################
#model functions interface
def detect_objects_as_image(image_cv2):
    results = model.detect(image_cv2, orders=['render'])
    image = results.imgs[0]
    return image

def detect_objects_as_data(image_cv2):
    results = model.detect(image_cv2, orders=['render'])
    image = results.imgs[0]
    json_to_client = model.get_json()
    return [image,json_to_client]
#####################################################################
#help functions
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def seperate_objects_into_images_api(image,array_positions,name):
    index=0
    check_folder_create("out_google_search")
    for single_record in array_positions:
        xmin = int(single_record['xmin'])
        ymin = int(single_record['ymin'])
        xmax = int(single_record['xmax'])
        ymax = int(single_record['ymax'])
        im1 = image.crop((xmin, ymin, xmax, ymax))
        final_name=str(name)+str(index)
        im1.save(f"out_google_search\\{final_name}.jpg")
        index+=1

#####################################################################
#cloud functions interface
@app.route('/', methods=['GET'])
def index():
    """Video streaming home page."""
    return render_template('index.html')


# old version to return the output image url to the client
@app.route('/api/photo', methods=[ 'POST'])
def upload_file_api():
    # check if the post request has the file part
    if 'file' not in request.files:
        return jsonify({"error":'No file part'})
    file = request.files['file']
    client_id=request.form.get('client_id')
    # If the user does not select a file, the browser submits an
    # empty file without a filename.
    if file.filename == '':
        return jsonify({"error":'No selected file'})
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        # error handling folder and client id 
        check_folder_create(UPLOAD_FOLDER+'\\'+client_id)
        image_name=UPLOAD_FOLDER+'\\'+client_id+'\\'+os.path.join(filename)
        file.save(image_name)

        recieved_image=Image.open(image_name)
        model_out=detect_objects_as_data(recieved_image)
        out_image=model_out[0]
        out_image = cv2.cvtColor(out_image, cv2.COLOR_BGR2RGB)
        # error handling folder and client id 
        check_folder_create(f"out_img\\{client_id}")
        cv2.imwrite(f"out_img\\{client_id}\\{os.path.join(filename)}", out_image)
        url_out=f"{domain}/image/{os.path.join(filename)}"
        #for google search api
        x = threading.Thread(target=seperate_objects_into_images_api, args=(recieved_image,json.loads(model_out[1]),client_id))
        x.start()
        json_return={
            'image_array':model_out[1],
            'image_out':url_out,
            'google_api_name':client_id
        }
        return jsonify(json_return)


@app.route('/api/new_client', methods=[ 'POST'])
def get_new_client():
    name = str(random.randint(0,1000000))
    # initialize a folder for client data
    directory = f'uploads\\{name}'
    directory1 = f'out_img\\{name}'
    path = os.path.join(parent_dir, directory) 
    path1 = os.path.join(parent_dir, directory1) 
    # to check the client is not exists with the same id
    while os.path.isdir(path):
        name = str(random.randint(0,1000000))
        # initialize a folder for client data
        directory = name
        path = os.path.join(parent_dir, directory) 
    os.makedirs(path) 
    os.makedirs(path1) 
    # send client id
    return name



# used to website application
@app.route('/photo', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            image_name=UPLOAD_FOLDER+'\\'+os.path.join(filename)
            file.save(image_name)
            out_image=detect_objects_as_image(cv2.imread(image_name))
            # out_image = cv2.cvtColor(out_image, cv2.COLOR_BGR2RGB)
            cv2.imwrite(f"out_img\\{os.path.join(filename)}", out_image)
            cv2.destroyAllWindows()
            return redirect(f"image/{os.path.join(filename)}")
    return '''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    '''

# for website application
@socketio.on('input image', namespace='/test')
def client_server_socket(input):
    #get image data as base64 (string)
    input = input.split(",")[1]
    #detecting function
    img = detect_objects_as_image(imread(input))
    #convert image color
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    #decode to base64 and sending back to client throught socket
    _ , buffer = cv2.imencode('.jpg', img)
    jpg_as_text = base64.b64encode(buffer)
    image_data=jpg_as_text.decode('utf-8')
    image_data = "data:image/jpeg;base64," + image_data
    emit('out-image-event', {'image_data': image_data}, namespace='/test')



#old version not best practice
@socketio.on('input image mobile', namespace='/test')
def return_object_as_image(input):
    f = io.BytesIO()
    f.write(base64.b64decode(input))
    f.seek(0)
    img = detect_objects_as_image(cv2.rotate(imread(f), cv2.cv2.ROTATE_90_CLOCKWISE))
    f.close()
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    _, buffer = cv2.imencode('.jpg', img)
    jpg_as_text = base64.b64encode(buffer)
    image_data=jpg_as_text.decode('utf-8')
    image_data =image_data
    emit('out-image-event-mobile', {'image_data': image_data}, namespace='/test')


##########important###############
@socketio.on('input image array', namespace='/test')
def return_object_as_data(input):
    f = io.BytesIO()
    f.write(base64.b64decode(input))
    f.seek(0)
    model_out=detect_objects_as_data(cv2.rotate(imread(f), cv2.cv2.ROTATE_90_CLOCKWISE))
    f.close()
    emit('out-image-event-array',model_out[1], namespace='/test')

########## receive the image from the client (mobile app) returns json data ###############
@app.route('/api/array', methods=[ 'POST'])
def upload_file_api_v2():
    # check if the post request has the file part
    if 'file' not in request.files:
        return jsonify({"error":'No file part'})
    file = request.files['file']
    # If the user does not select a file, the browser submits an
    # empty file without a filename.
    if file.filename == '':
        return jsonify({"error":'No selected file'})
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        image_name=UPLOAD_FOLDER+'\\'+os.path.join(filename)
        file.save(image_name)
        model_out=detect_objects_as_data(imread(image_name))
        json_return={
            'image_array': model_out[1],
        }
        return jsonify(json_return)

        

@socketio.on('connect', namespace='/test')
def test_connect():
    print("client connected")

@app.route("/api/get_cloud", methods=['POST'])
def get_cloud():
    client_id=request.form.get('client_id')
    out_urls=[]
    client_photos=glob.glob(f"out_img/{client_id}/*")
    for single_photo in client_photos:
        image_name=single_photo.split("\\")[1]
        out_urls.append(f"{domain}/image/{client_id}/{image_name}")
    json_return={
        'images_url':out_urls,
    }
    return jsonify(json_return)

#####################################################################
#access images that have been saved on cloud
@app.route("/image/<path:filename>", methods=['GET'])
def show_img1(filename):
    return send_file(f"out_img\\{filename}")

# url to search with photo to google api
"""
on the client side just call that url and it will redirect you to google search with the opject you have selected
https://www.google.com/searchbyimage?site=search&sa=X&image_url={domain}/image_search/{name}{index}.jpg
"""
@app.route("/image_search/<path:filename>", methods=['GET'])
def show_img2(filename):
    return send_file(f"out_google_search\\{filename}")

if __name__ == '__main__':
    socketio.run(app, port=5000)