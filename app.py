from sys import stdout
# from makeup_artist import Makeup_artist
import logging
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

#notes
"""
-mobile:
"""
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
app = Flask(__name__)
app.logger.addHandler(logging.StreamHandler(stdout))
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = True
socketio = SocketIO(app,cors_allowed_origins="*")
#####################################################################
model = Yolo()
#####################################################################

def detect_img(image_cv2):
    results = model.detect(image_cv2, orders=['render'])
    image = results.imgs[0]
    return image

def detect_img_w_array(image_cv2):
    results = model.detect(image_cv2, orders=['render'])
    image = results.imgs[0]
    json_to_client = model.get_json()

    return [image,json_to_client]
#####################################################################
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

#####################################################################
@app.route('/', methods=['GET'])
def index():
    """Video streaming home page."""
    return render_template('index.html')

@app.route('/api/photo', methods=[ 'POST'])
def upload_file_api():
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
        model_out=detect_img_w_array(imread(image_name))
        out_image=model_out[0]
        out_image = cv2.cvtColor(out_image, cv2.COLOR_BGR2RGB)
        cv2.imwrite(f"out_img\\{os.path.join(filename)}", out_image)
        domain='https://2133-41-44-118-135.ngrok.io'
        url_out=f"{domain}/image/{os.path.join(filename)}"
        #cv2.destroyAllWindows()
        json_return={
            'image_array':model_out[1],
            'image_out':url_out
        }
        return jsonify(json_return)


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
            out_image=detect_img(cv2.imread(image_name))
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

@socketio.on('input image', namespace='/test')
def test_message(input):
    #get image data as base64 (string)
    input = input.split(",")[1]
    #write in memory for fast accessing
    f = io.BytesIO()
    f.write(base64.b64decode(input))
    f.seek(0)
    #detecting function
    img = detect_img(imread(f))
    f.close()
    #convert image color
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    #decode to base64 and sending back to client throught socket
    _ , buffer = cv2.imencode('.jpg', img)
    jpg_as_text = base64.b64encode(buffer)
    image_data=jpg_as_text.decode('utf-8')
    image_data = "data:image/jpeg;base64," + image_data
    emit('out-image-event', {'image_data': image_data}, namespace='/test')


@socketio.on('input image mobile', namespace='/test')
def test_message(input):
    print("============")
    f = io.BytesIO()
    f.write(base64.b64decode(input))
    f.seek(0)
    img = detect_img(cv2.rotate(imread(f), cv2.cv2.ROTATE_90_CLOCKWISE))
    f.close()
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    _, buffer = cv2.imencode('.jpg', img)
    jpg_as_text = base64.b64encode(buffer)
    image_data=jpg_as_text.decode('utf-8')
    image_data =image_data
    emit('out-image-event-mobile', {'image_data': image_data}, namespace='/test')


##########important###############
@socketio.on('input image array', namespace='/test')
def test_message_2(input):
    f = io.BytesIO()
    f.write(base64.b64decode(input))
    f.seek(0)
    model_out=detect_img_w_array(imread(f))
    f.close()
    # img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    emit('out-image-event-array',model_out[1], namespace='/test')

##########important###############
@app.route('/api/array', methods=[ 'POST'])
def upload_file_api_2():
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
        model_out=detect_img_w_array(imread(image_name))
        json_return={
            'image_array':model_out[1],
        }
        return jsonify(json_return)

        

@socketio.on('connect', namespace='/test')
def test_connect():
    print("client connected")

@socketio.on("try", namespace='/test')
def test_message(input):
    print(input)

@app.route("/image/<path:filename>", methods=['GET'])
def show_img(filename):
    return send_file(f"out_img\\{filename}")

if __name__ == '__main__':
    socketio.run(app, port=5000)