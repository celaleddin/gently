;;;; General

(defn join-names [&rest args &kwonly [sep " "]]
  (.join sep (map name args)))


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
  `~@(lfor form forms
           `(assert ~form
                    (+ "Test failed: " (name '~form)))))

(defmacro run-tests []
  `(lfor function ~*test-functions-symbol*
         (function)))
