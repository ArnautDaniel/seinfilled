
(asdf:defsystem seinfilled
  :version "1.1.0"
  :license "MIT"
  :author "Jack Lucas <silverbeard@protonmail.com>"
  :description "Invoice Writeup Tool"
  :serial T
  :components (
	       (:file "seinfilled")
	       (:file "images")
               (:file "viewer")
               (:file "gallery"))
  :defsystem-depends-on (:qtools)
  :depends-on (:qtools
               :qtcore
               :qtgui
               :qtopengl
               :uiop
               :verbose
               :simple-tasks
               :bordeaux-threads)
  :build-operation "qt-program-op"
  :build-pathname "seinfilled"
:entry-point "seinfilled:start")

