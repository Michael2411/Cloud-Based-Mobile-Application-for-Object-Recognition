import cv2
import torch
import time
import warnings
warnings.filterwarnings("ignore", message="torch.distributed.reduce_op is deprecated")
class Yolo():
    __instance = None
    @staticmethod
    def get_instance():
        if Yolo.__instance == None:
            Yolo()
        return Yolo.__instance

    def __init__(self, model_name='yolov5x'):
        if Yolo.__instance != None:
            raise Exception("Error multiple instances")
        else:
            Yolo.__instance = self
        self.model = torch.hub.load('ultralytics/yolov5', model_name)
        self.results = None
    
    def detect(self, imgs, orders=['render', 'save', 'show']):
        self.results = self.model(imgs)  # includes NMS
        # Results
        for order in orders:
            if order == 'render':
                self.results.render()
            elif order == 'show':
                self.results.show()
            elif order == 'save':
                self.results.save()
        return self.results

    def get_json(self):
        df = self.results.pandas().xyxy[0]
        start = time.time()
        del df['confidence']
        del df['class']
        df = df.apply(lambda x: round(x) if x.name in ['xmin','ymin', 'xmax', 'ymax'] else x)
        print(time.time()-start)
        json = df.to_json(orient="records")
        return json

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