(load "~/quicklisp/setup.lisp")
(ql:quickload "swank")
(swank:create-server :port 4005 :style :spawn :dont-close t)

(asdf:initialize-source-registry
 '(:source-registry
   (:tree "/home/herwig/checkout/jwacs/")
   :inherit-configuration))
(require :jwacs)
(require :jwacs-tests)

(in-package :jwacs)
(start-cps-server "localhost" 1337)

#+_(ql:quickload "cl-ppcre")
#+_(ql:quickload "asdf")
#+_(ql:quickload "uiop")
#+_(ql:quickload "trivial-shell")
#+_(ql:quickload "rt")
#+_(ql:quickload "usocket")
#+_(ql:quickload "bt-semaphore")
#+_(load "~/checkout/jwacs/jwacs.asd")
#+_(load "~/checkout/jwacs/jwacs-tests.asd")
#+_(load "~/checkout/jwacs/package.lisp")
#+_(load "~/checkout/jwacs/tests/package.lisp")

