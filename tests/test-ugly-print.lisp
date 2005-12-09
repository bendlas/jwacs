;;;; test-ugly-print.lisp
;;;
;;; Tests for the ugly printer

(in-package :jwacs-tests)

;;;; Helper functions
(defun ugly-string (elm)
  "Uglyprint LM to a tring value instead of a stream"
  (with-output-to-string (s)
    (ugly-print elm s)))

(defmacro with-fresh-genvar (&body body)
  "Make sure that GENVAR variable names will start from 0 and that
   continuation arguments will have a known value"
  `(let* ((*genvar-counter* 0))
    ,@body))

;;;; Test category
(defnote ugly-print "tests for the ugly printer")

(deftest ugly-print/var-decl/1 :notes ugly-print
  (with-fresh-genvar
      (ugly-string (parse "var x = 3;")))
    "var JW0=3;")

(deftest ugly-print/function-decl/1 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(){;}")))
  "function JW0(){;}")

(deftest ugly-print/function-decl/2 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(x){;}")))
  "function JW0(JW1){;}")

(deftest ugly-print/function-decl/3 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(x){ var y = x; }")))
  "function JW0(JW1){var JW2=JW1;}")

(deftest ugly-print/function-decl/4 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(){ FOO(); }")))
  "function JW0(){JW0();}")

(deftest ugly-print/function-decl/5 :notes ugly-print
  (with-fresh-genvar
    (jw::uglify-vars (parse "
      function recursiveCount(i, n)
      {
        if(i > n)
          return i - 1;
        else
        {
          WScript.echo(i + '/' + n);
          return recursiveCount(i + 1, n);
        }
      }")))
  #.(parse "
      function JW0(JW1, JW2)
      {
        if(JW1 > JW2)
          return JW1 - 1;
        else
        {
          WScript.echo(JW1 + '/' + JW2);
          return JW0(JW1 + 1, JW2);
        }
      }"))

;; ensure vardecls in blocks shadow function vars
;;
;;    function foo(x) <-- this x could be JW0
;;    {
;;        var x = 3;  <-- this x should be JW1 not 0
;;        bar(x);     <-- this x should be JW1
;;    }
;;
(deftest ugly-print/function-decl-arg-shadow/1 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(x){ var x = 3; }")))
  "function JW0(JW1){var JW2=3;}")
    

(deftest ugly-print/function-decl-arg-shadow/2 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(x){ var x = 3; FOO(x);}")))
  "function JW0(JW1){var JW2=3;JW0(JW2);}")

(deftest ugly-print/function-in-function/1 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(x) {
                          function BAR(z) {
                             return z + y;
                          }
                          var y = 3;
                          bar(3); 
                         }")))
  "function JW0(JW1){function JW3(JW4){return JW4+JW2;}var JW2=3;JW3(3);}")

(deftest ugly-print/function-in-function/2 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(x) {
                          var y = 3;
                          function BAR(z) {
                             return z + y;
                          }
                          bar(3); 
                         }")))
  "function JW0(JW1){var JW2=3;function JW3(JW4){return JW4+JW2;}JW3(3);}")

(deftest ugly-print/function-in-function-in-function/1 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "function FOO(x) {
                          function BAR(z) {
                            function BAZ(xz) {
                                return 3 + y;
                             }
                             return z + y + BAZ(3);
                          }
                          var y = 3;
                          bar(3); 
                         }")))
"function JW0(JW1){function JW3(JW4){function JW5(JW6){return 3+JW2;}return JW4+JW2+JW5(3);}var JW2=3;JW3(3);}")

(deftest ugly-print/blocks/1 :notes ugly-print
 (with-fresh-genvar
   (ugly-string (parse "{ var y = 3;
                           {
                              var x = 1;
                           }
                          x + y;
                        }")))
   "{var JW0=3;{var JW1=1;};JW1+JW0;};")

(deftest ugly-print/free-variables/1 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "var x = 10;
                         var y = x + z;")))
    "var JW0=10;var JW1=JW0+z;")

(deftest ugly-print/free-variables/2 :notes ugly-print
  (with-fresh-genvar
    (ugly-string (parse "var x = foo;
                         function bar(m)
                         {
                           var y=m*2;
                           if(y > x)
                             return bar(m--);
                           else
                             return m;
                         }")))
  "var JW0=foo;function JW1(JW2){var JW3=JW2*2;if(JW3>JW0)return JW1(JW2--);else return JW2;}")

