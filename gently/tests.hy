(import gently)

(require [gently.language [define
                           define-transfer-function
                           documentation]])
(require [gently.utils [register-tests
                        run-tests]])


(register-tests
  (defn test-define []
    (define a 3 "A docstring")
    (define b 5)
    (assert (= a 3))
    (assert (= (documentation a) "A docstring"))
    (assert (.startswith (documentation b) "No documentation")))

  (defn test-define-tf []
    (define a 10)
    (define-transfer-function a-system
      (:numerator 2)
      (:denominator s^2 + 5*a*s + 10)
      ;; (:sampling-period 0.1)
      (:documentation "A transfer function representing a system."))
    (print a-system)))


(defmain [&rest args]
    (run-tests))
