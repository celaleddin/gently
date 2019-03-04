(import [gently.language [*]])
(require [gently.language [*]])
(require [gently.utils [register-tests run-tests assert-all
                        get-docstring]])


(register-tests
  (defn test-define []
    (define a 3 "A docstring")
    (define b 5)
    (assert-all
      (= a 3)
      (= b 5)
      (= (documentation a) "A docstring")
      (.startswith (documentation b) "No documentation")))

  (defn test-define-tf []
    (define-transfer-function a-system
      "A transfer function representing a system"
      (numerator 4*s + 5)
      (denominator s^2 + 5*a*s + 10)
      (sampling-period 0.1))
    (assert-all
      (= (str (numerator a-system)) "4*s + 5")
      (= (str (denominator a-system)) "5*a*s + s^2 + 10")
      (= (str (sampling-period a-system)) "0.1")
      (.startswith (documentation a-system) "A transfer fun"))))


(defmain [&rest args]
    (run-tests))
