import cv2

cam = cv2.VideoCapture(0)
while 1:
     _,frame =cam.read()
     cv2.imshow("features", frame)
     if cv2.waitKey(10) == 0x1b: # ESC
         print("ESC pressed. Exiting ...")
         break
