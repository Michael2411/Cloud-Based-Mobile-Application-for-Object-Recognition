import cv2
import torch
import time
import warnings
warnings.filterwarnings("ignore", message="torch.distributed.reduce_op is deprecated")
class Yolo():
    def __init__(self, model_name='yolov5m'):
        self.model = torch.hub.load('ultralytics/yolov5', model_name,  _verbose=False)
        self.results = None

    def get_results(self):
        return self.results

    def video_detector(self, ratio=(480, 640), fps=None, img_size=416, delay_ms=50):
        cap=cv2.VideoCapture(0)
        cap.set(3,ratio[0])
        cap.set(4,ratio[1])
        if fps:
            cap.set(5,fps)
        while(cap.isOpened()):
            ret,image=cap.read()
            if ret == True:
                self.results = self.model(image, size=img_size)

                self.results.render()  # updates results.imgs with boxes and labels

                cv2.imshow("object detection", self.results.imgs[0])
                cv2.waitKey(delay_ms)

                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            else:
                break
        cap.release()
        cv2.destroyAllWindows()
        return True
    
    def detect(self, imgs, orders=['render', 'save', 'show']):
        # self.results = self.model(imgs, size=img_size)
        self.results = self.model(imgs)  # includes NMS
        # Results
        # self.results.render()
        for order in orders:
            if order == 'render':
                self.results.render()
            elif order == 'show':
                self.results.show()
            elif order == 'save':
                self.results.save()
        return self.results

    def get_json(self):
        return self.results.pandas().xyxy[0].to_json(orient="records")

# model = Yolo()

# img2 = cv2.imread('bus.jpg')[..., ::-1]  # OpenCV image (BGR to RGB)


# # # Inference
# start = time.time()

# # model = net.get_model()  # includes NMS
# results = model.detect(img2)
