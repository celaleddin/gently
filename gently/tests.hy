(import [sympy [Symbol]])

(import [gently.language [*]])
(require [gently.language [*]])

(import [gently.math [Poly]])
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
    (define-transfer-function a-system
      "A transfer function representing a system"
      (numerator 4*s + 5)
      (denominator s^2 + 5*(a+3)*s + 10)
      (sampling-period 0.1))
    (assert-all
      (= (.coeff-list (numerator a-system)) [4 5])
      (= (denominator a-system) (Poly "s^2 + 5*(a+3)*s + 10" (Symbol "s")))
      (= (sampling-period a-system) 0.1)
      (.startswith (documentation a-system) "A transfer fun")))

  (defn test-tf-tag []
    (define tf #tf(1/(s^2+5)))
    (assert-all
      (= (.coeff-list (numerator tf)) [1])
      (= (.coeff-list (denominator tf)) [1 0 5])))

  (defn test-connect-o []
    (define result (o
                     (> #tf(1) #tf(5))
                     (> #tf(2) #tf(3))
                     (^ #tf(7) #tf(1))))
    (assert-all
      (= (.coeff-list (numerator result)) [11])
      (= (.coeff-list (denominator result)) [78]))))


(run-tests)
