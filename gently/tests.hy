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
      (= (get-docstring a) "A docstring")
      (.startswith (get-docstring b) "No documentation")))

  (defn test-define-tf []
    (define-transfer-function a-system
      "A transfer function representing a system"
      (numerator 4*s + 5)
      (denominator s^2 + 5*s + 10)
      (sampling-period 0.1))
    (assert-all
      (= (.num-as-str a-system) "4*s + 5")
      (= (.den-as-str a-system) "s^2 + 5*s + 10")
      (= (.dt-as-str a-system) "0.1")
      (.startswith (get-docstring a-system) "A transfer fun"))))


(defmain [&rest args]
    (run-tests))
