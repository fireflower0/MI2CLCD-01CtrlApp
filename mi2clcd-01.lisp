;; Load packages
(load "packages.lisp" :external-format :utf-8)

(in-package :cl-cffi)

;; Load wrapper API
(load "libwiringPi.lisp" :external-format :utf-8)

;; I2C device address (0x3e)
(defconstant +i2c-addr+ #X3E)

;; LCD contrast (0x00-0x0F)
(defconstant +contrast+ #X0A)

;; LCD column (16)
(defconstant +column+ 16)

(defun i2c-lcd ()
  (setq fd (wiringPiI2CSetup +i2c-addr+))

  (setq fcnt (logior (logand +contrast+ #X0F) #X70))
  
  (wiringPiI2CWriteReg8 fd #X00 #X38) ; Function set : 8bit, 2 line
  (wiringPiI2CWriteReg8 fd #X00 #X39) ; Function set : 8bit, 2 line, IS=1
  (wiringPiI2CWriteReg8 fd #X00 #X14) ; Internal OSC freq
  (wiringPiI2CWriteReg8 fd #X00 fcnt) ; Contrast set
  (wiringPiI2CWriteReg8 fd #X00 #X5F) ; Power/ICON/Constract
  (wiringPiI2CWriteReg8 fd #X00 #X6A) ; Follower control
  (delay 300)                         ; Wait time (300 ms)
  (wiringPiI2CWriteReg8 fd #X00 #X39) ; Function set : 8 bit, 2 line, IS=1
  (wiringPiI2CWriteReg8 fd #X00 #X06) ; Entry mode set
  (wiringPiI2CWriteReg8 fd #X00 #X0C) ; Display on/off
  (wiringPiI2CWriteReg8 fd #X00 #X01) ; Clear display
  (delay 30)                          ; Wait time (0.3 ms)
  (wiringPiI2CWriteReg8 fd #X00 #X02) ; Return home
  (delay 30)                          ; Wait time (0.3 ms)

  (with-ltk ()
    (wm-title *tk* "MI2CLCD-01 Control Application")
    (bind *tk* "<Alt-q>" (lambda (event)
                           (setq *exit-mainloop* t)))
    (let ((lbl1 (make-instance 'label :text "First line" :width 60))
          (entry1 (make-instance 'entry))
          (btn1 (make-instance 'button :text "Button1"))
          (lbl2 (make-instance 'label :text "Second line" :width 60))
          (entry2 (make-instance 'entry))
          (btn2 (make-instance 'button :text "Button2")))
      (setf (command btn1) (lambda ()
                             ;; Set cursor first line
                             (wiringPiI2CWriteReg8 fd #X00 #X80)
                             ;; Clear first line
                             (dotimes (count +column+)
                               (wiringPiI2CWriteReg8 fd #X40 #X20))
                             ;; Reset cursor first line
                             (wiringPiI2CWriteReg8 fd #X00 #X80)
                             ;; Display string
                             (loop :for char :across (text entry1)
                                   :do (wiringPiI2CWriteReg8 fd #X40 (char-code char)))))
      (setf (command btn2) (lambda ()
                             ;; Set cursor first line
                             (wiringPiI2CWriteReg8 fd #X00 #XC0)
                             ;; Clear first line
                             (dotimes (count +column+)
                               (wiringPiI2CWriteReg8 fd #X40 #X20))
                             ;; Reset cursor first line
                             (wiringPiI2CWriteReg8 fd #X00 #XC0)
                             ;; Display string
                             (loop :for char :across (text entry2)
                                   :do (wiringPiI2CWriteReg8 fd #X40 (char-code char)))))
      (focus entry1)
      (pack (list lbl1 entry1 btn1 lbl2 entry2 btn2) :fill :x))

    ;; Icon Control Button
    (let* ((f (make-instance 'frame))
           (lbl3 (make-instance 'label :text "Icon Control Button"))
           (b1 (make-instance 'button :text "Antenna"))
           (b2 (make-instance 'button :text "Phone"))
           (b3 (make-instance 'button :text "Sound"))
           (b4 (make-instance 'button :text "Input"))
           (b5 (make-instance 'button :text "Up"))
           (b6 (make-instance 'button :text "Down"))
           (b7 (make-instance 'button :text "KeyLock"))
           (b8 (make-instance 'button :text "Mute"))
           (b9 (make-instance 'button :text "Battery1"))
           (bA (make-instance 'button :text "Battery2"))
           (bB (make-instance 'button :text "Battery3"))
           (bC (make-instance 'button :text "Battery4"))
           (bD (make-instance 'button :text "Other"))
           (bClr (make-instance 'button :text "Clear")))
      (setf (command b1) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X40)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command b2) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X42)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command b3) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X44)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command b4) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X46)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command b5) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X47)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command b6) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X47)
                           (wiringPiI2CWriteReg8 fd #X40 #X08)))
      (setf (command b7) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X49)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command b8) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X4B)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command b9) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X4D)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command bA) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X4D)
                           (wiringPiI2CWriteReg8 fd #X40 #X08)))
      (setf (command bB) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X4D)
                           (wiringPiI2CWriteReg8 fd #X40 #X04)))
      (setf (command bC) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X4D)
                           (wiringPiI2CWriteReg8 fd #X40 #X02)))
      (setf (command bD) (lambda ()
                           (wiringPiI2CWriteReg8 fd #X00 #X4F)
                           (wiringPiI2CWriteReg8 fd #X40 #X10)))
      (setf (command bClr) (lambda ()
                            ;; Antenna clear
                            (wiringPiI2CWriteReg8 fd #X00 #X40)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)
                            ;; Phone clear
                            (wiringPiI2CWriteReg8 fd #X00 #X42)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)
                            ;; Sound clear
                            (wiringPiI2CWriteReg8 fd #X00 #X44)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)
                            ;; Input clear
                            (wiringPiI2CWriteReg8 fd #X00 #X46)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)
                            ;; Up Down clear
                            (wiringPiI2CWriteReg8 fd #X00 #X47)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)
                            ;; KeyLock clear
                            (wiringPiI2CWriteReg8 fd #X00 #X49)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)
                            ;; Mute clear
                            (wiringPiI2CWriteReg8 fd #X00 #X4B)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)
                            ;; Battery clear
                            (wiringPiI2CWriteReg8 fd #X00 #X4D)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)
                            ;; Other clear
                            (wiringPiI2CWriteReg8 fd #X00 #X4F)
                            (wiringPiI2CWriteReg8 fd #X40 #X00)))
      (pack lbl3)
      (pack (list b1 b2 b3 b4 b5 b6 b7 b8 b9 bA bB bC bD) :side :left)
      (pack bClr :fill :x)
      (configure f :borderwidth 3)
      (configure f :relief :sunken))))

;; Execution
(i2c-lcd)
