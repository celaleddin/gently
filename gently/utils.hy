(import io)

(import [hy.models [HySequence HyExpression HyDict]])


;;;; General

(defn join-names [&rest args &kwonly [sep " "]]
  "Join names of `args` into a string by separating them with `sep`"
  (.join sep (map name args)))

(defn expr->string [expr]
  "Turn an expression into a string"
  (setv brackets (if (isinstance expr HyExpression) ["(" ")"]
                     (isinstance expr HyList) ["[" "]"]
                     (isinstance expr HyDict) ["{" "}"]
                     ["(" ")"]))
  (if (isinstance expr HySequence)
      (+ (get brackets 0)
         (join-names #* (lfor e expr (expr->string e)))
         (get brackets 1))
      (name expr)))

(defn print-to-string [&rest args &kwargs kwargs]
  "Print `args` into a string using the builtin `print` function"
  (setv out (io.StringIO))
  (print #* args :file out #** kwargs)
  (setv content (.getvalue out))
  (.close out)
  content)

(defn macroexpander [form]
  "Make macroexpansions readable for humans"
  (expr->string (macroexpand-1 form)))

(defmacro/g! local-numbers []
  "Filter `(locals)` for string keys and number values"
  `(do
     (import [numbers [Number :as ~g!number]])
     (dfor (, k v) (.items (locals))
         :if (and (isinstance k str)
                  (isinstance v ~g!number))
         [k v])))


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
  `(do
     (import [gently.utils [expr->string]])
     ~@(lfor form forms
             `(assert ~form
                      (+ "\nTest failed: "
                         (expr->string '~form))))))

(defmacro run-tests []
  "Run test functions registered inside the `register-tests`"
  `(for [function ~*test-functions-symbol*]
     (do (function) (print "." :end ""))
     (else (print "\nTests passed!"))))


;;;; Documentation string related

(defclass Docstring [str]
  "A string with a non-quoting --repr-- function"
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
