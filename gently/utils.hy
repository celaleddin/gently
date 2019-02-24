(import io)


;;;; General

(defn join-names [&rest args &kwonly [sep " "]]
  "Join names of `args` seperated by `sep` into a string"
  (.join sep (map name args)))

(defn print-to-str [&rest args &kwargs kwargs]
  "Print `args` into a string using builtin `print` function"
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
     (setv ~*test-functions-symbol* [])
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
  `(lfor function ~*test-functions-symbol*
         (function)))


;;;; Documentation string related

(defmacro set-docstring [symbol docstring]
  `(setattr ~symbol "**doc**" ~docstring))

(defmacro get-docstring [symbol]
  `(getattr ~symbol "**doc**"
            (% "No documentation found for symbol '%s'" (name '~symbol))))
