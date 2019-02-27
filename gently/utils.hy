(import io)


;;;; General

(defn join-names [&rest args &kwonly [sep " "]]
  "Join names of `args` into a string by separating them with `sep`"
  (.join sep (map name args)))

(defn print-to-str [&rest args &kwargs kwargs]
  "Print `args` into a string using the builtin `print` function"
  (setv out (io.StringIO))
  (print #* args :file out #** kwargs)
  (setv content (.getvalue out))
  (.close out)
  content)


;;;; Test related

(setv *test-functions-symbol* (gensym "test-functions"))

(defmacro register-tests [&rest functions]
  "Register functions as tests which will be runned with `run-tests`"
  `(do
     (try ~*test-functions-symbol*
          (except [NameError] (setv ~*test-functions-symbol* [])))
     (defn register-test [function]
       (.append ~*test-functions-symbol* function) function)
     ~@(lfor function functions
             `(with-decorator register-test
                ~function))))

(defmacro assert-all [&rest forms]
  "Shorthand for asserting multiple forms"
  `~@(lfor form forms
           `(assert ~form
                    (+ "Test failed: " (name '~form)))))

(defmacro run-tests []
  "Run test functions registered inside the `register-tests`"
  `(for [function ~*test-functions-symbol*]
     (do (function) (print "." :end ""))
     (else (print "\nTests passed!"))))


;;;; Documentation string related

(defclass Docstring [str]
  (defn --repr-- [self] self))

(defmacro set-docstring [symbol docstring]
  "Set documentation string `docstring` for `symbol`"
  `(do
     (import gently.utils)
     (setattr ~symbol "**doc**" (gently.utils.Docstring ~docstring))))

(defmacro get-docstring [symbol]
  "Get documentation string of `symbol` if it is available"
  `(getattr ~symbol "**doc**"
            (% "No documentation found for symbol '%s'" (name '~symbol))))
