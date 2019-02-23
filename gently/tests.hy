(require [gently.language [define define-transfer-function
                           documentation]])
(require [gently.utils [register-tests run-tests assert-all]])


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
    (define a 10)
    (define-transfer-function a-system
      "A transfer function representing a system"
      (:numerator 2)
      (:denominator s^2 + 5*a*s + 10)
      (:sampling-period 0.1))
    (print a-system)))


(defmain [&rest args]
    (run-tests))
