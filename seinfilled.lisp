(in-package #:cl-user)
(defpackage #:seinfilled
  (:use #:cl+qt)
  (:export
   #:main
#:start))

(in-package #:seinfilled)
(in-readtable :qtools)

(defvar *main*)

(define-widget dock-container (QDockWidget)
  ((widget :initarg :widget :reader widget)
   (title :initarg :title :reader :title))
  (:default-initargs
      :widget (error "Widget required.")
    :title ""))

(define-initializer (dock-container setup)
  (setf (q+:widget dock-container) widget)
  (setf (q+:window-title dock-container) title)
  (setf (q+:features dock-container) (q+:qdockwidget.dock-widget-movable)))

(define-widget main-window (QMainWindow)
  ())

(define-initializer (main-window set-main 100)
  (setf *main* main-window)
  (setf (q+:window-title main-window) "SeinFilled")
  (q+:resize main-window 1024 768))


(define-subwidget (main-window viewer) (make-instance 'viewer))
(define-subwidget (main-window gallery) (make-instance 'gallery))


#| Added Area |#
(define-widget  line-edit (QLineEdit)
    ((name :initarg :name :accessor edit-name))
  (:default-initargs :name "NA"))


(defun make-button (widget text)
  (let ((button (q+:make-qpushbutton widget)))
    (setf (q+:text button) text)
    button))

(defun make-lineedit (text)
  (let ((lineedit (make-instance 'line-edit :name text)))
    (q+:set-placeholder-text lineedit text)
    lineedit))

(define-subwidget (main-window desc-edit) (make-lineedit "Description"))
(define-subwidget (main-window price-edit) (make-lineedit "Price$"))
(define-subwidget (main-window qty-edit) (make-lineedit "Quantity#"))
(define-subwidget (main-window add) (make-button main-window "Add Item"))
(define-subwidget (main-window final) (make-button main-window "Finalize"))

(define-subwidget (main-window layout) (q+:make-qvboxlayout main-window)
  (q+:add-widget layout viewer)
  (let ((inner (q+:make-qformlayout)))
    (q+:add-widget inner desc-edit)
    (q+:add-widget inner price-edit)
    (q+:add-widget inner qty-edit)
    (q+:add-widget inner  add)
    (q+:add-widget inner final)
    (q+:add-layout layout inner))
  (let ((widget (q+:make-qwidget main-window)))
    (setf (q+:layout widget) layout)
    (setf (q+:central-widget main-window) widget)))
#| End Added Area |#

(define-subwidget (main-window dockable) (make-instance 'dock-container :widget gallery :title "Gallery")
  (q+:add-dock-widget main-window (q+:qt.bottom-dock-widget-area) dockable))

(defgeneric (setf image) (image thing)
  (:method (thing (main main-window))
    (with-slots-bound (main main-window)
      (setf (image viewer) thing)
      (setf (image gallery) thing))))

(define-menu (main-window File)
  (:item ("New Show" (ctrl o))
	 (let ((dir (q+:qfiledialog-get-existing-directory main-window "Browse" (uiop:native-namestring (location gallery)))))
	   (unless (or (qt:null-qobject-p dir) (string= dir ""))
	     (setf (location gallery) (uiop:parse-native-namestring dir :ensure-directory T)))))
  (:item ("Quit" (ctrl q))
	 (q+:close main-window)))

(defun main ()
  (unwind-protect
       (progn
	 (bt:make-thread (lambda () (simple-tasks:start-runner *image-runner*)))
	 (with-main-window (window 'main-window :name "SeinFilled")
	   (with-slots-bound (window main-window)
	     (setf (location gallery) (user-homedir-pathname)))))
    (simple-tasks:stop-runner *image-runner*)))

(defun start ()
  #+:sbcl (sb-ext:disable-debugger)
  (setf v:*global-controller* (v:make-standard-global-controller))
  (let ((*main* NIL))
    (main)))

(deploy:define-hook (:deploy stop-verbose) ()
  (v:remove-global-controller))
