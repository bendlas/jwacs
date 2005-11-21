;;;; test-source-transformation.lisp
;;;
;;; Tests for the source transformations.

(in-package :jwacs-tests)

;;;;= Helper functions =
(defmacro with-fresh-genvars ((cont-name) &body body)
  "Make sure that GENVAR variable names will start from 0 and that
   continuation arguments will have a known value"
  `(let* ((*genvar-counter* 0)
          (*cont-name* ,cont-name)
          (*cont-id* (make-identifier :name *cont-name*)))
    ,@body))

;;;;= Test categories =
(defnote source-transformations "tests for the source-transformations")
(defnote cps "tests for the cps transformation")
(defnote explicitization "tests for the explicitization transformation")
    
;;;;= Tests =

;;;;== General traversal behaviour ==
(defmethod transform ((xform (eql 'hello)) (elm string))
    "hello there!")

(deftest source-transformations/general-behaviour/1 :notes source-transformations
  (transform 'hello #S(continue-statement :label "go away!"))
  #S(continue-statement :label "hello there!"))

(deftest source-transformations/general-behaviour/2 :notes source-transformations
  (transform 'hello '("string 1" symbol ("string 2")))
  ("hello there!" symbol ("hello there!")))

;;;;== CPS transformation ==
(deftest cps/factorial/1 :notes cps
  (with-fresh-genvars ("$k")
    (transform 'cps (parse "
       function factorial1(n)
       {
         if(n == 0)
           return 1;
         else
         {
           var r1 = factorial1(n-1);
           return n * r1;
         }
       }")))
  (#s(function-decl
      :name "factorial1" :parameters ("$k" "n")
      :body (#s(if-statement
                :condition
                #s(binary-operator :op-symbol :equals
                                   :left-arg #s(identifier :name "n")
                                   :right-arg #s(numeric-literal :value 0))
                :then-statement
                #s(cps-return :arg
                              #s(fn-call :fn #s(identifier :name "$k")
                                         :args (#s(numeric-literal :value 1))))
                :else-statement
                #s(statement-block
                   :statements
                   (#s(cps-return
                       :arg
                       #s(fn-call :fn #s(identifier :name "factorial1")
                                  :args
                                  (#s(function-expression
                                      :parameters ("r1")
                                      :body (#s(cps-return
                                                :arg #s(fn-call :fn #s(identifier :name "$k")
                                                                :args (#s(binary-operator :op-symbol :multiply
                                                                                          :left-arg #s(identifier :name "n")
                                                                                          :right-arg #s(identifier :name "r1")))))))
                                     #s(binary-operator :op-symbol :subtract
                                                        :left-arg #s(identifier :name "n")
                                                        :right-arg #s(numeric-literal :value 1))))))))))))

;;;;== Explicitization transformation ==
