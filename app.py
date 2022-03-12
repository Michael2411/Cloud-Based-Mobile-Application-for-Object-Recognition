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
# from to_png import yuvtorgb,RGBfromYUV,RGBfromYUV,yuvtorgb1
import io

from yolov5_class import Yolo


model = Yolo()


def detect_img(image_cv2):
    results = model.detect(image_cv2, orders=['render'])
    image = results.imgs[0]
    return image

def detect_img_w_array(image_cv2):
    results = model.detect(image_cv2, orders=['render'])
    image = results.imgs[0]
    json_to_client = model.get_json()

    return [image,json_to_client]
