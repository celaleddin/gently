;;;; General

(import [numbers [Number]])

(defn join-names [&rest args &kwonly [sep " "]]
  (.join sep (map name args)))

(defn only-number-values [dictionary]
  (dfor (, k v) (.items dictionary)
        :if (and (isinstance k str)
                 (isinstance v Number))
        [k v]))


;;;; Documentation string related

(defmacro attach-docstring [symbol docstring]
  `(setattr ~symbol "**doc**" ~docstring))

;;;; Test related

(setv *test-functions-symbol* (gensym "test-functions"))

(defmacro register-tests [&rest functions]
  `(do
     (setv ~*test-functions-symbol* [])
     (defn register-test [function]
       (.append ~*test-functions-symbol* function) function)
     ~@(lfor function functions
             `(with-decorator register-test
                ~function))))

(defmacro assert-all [&rest forms]
  `(do
     (import [gently.utils [join-names]])
     ~@(lfor form forms
             `(assert ~form
                      (+ "Test failed: " (name '~form))))))

(defmacro run-tests []
  `(lfor function ~*test-functions-symbol*
         (function)))
