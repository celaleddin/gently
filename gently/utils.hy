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

(setv *docstring-dict* (dict))

(defmacro attach-docstring [symbol docstring]
  `(assoc gently.utils.*docstring-dict*
          (gently.utils.join-names (id ~symbol) ~symbol)
          ~docstring))

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

(defmacro run-tests []
  `(lfor function ~*test-functions-symbol*
         (function)))
