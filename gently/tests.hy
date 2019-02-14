(require [gently.control.language [define-transfer-function
                                   documentation]])

(define-transfer-function a-system
  (:numerator 2)
  (:denominator s^2 + 5*s + 10)
  ;; (:sampling-period 0.1)
  (:documentation "A transfer function representing a system."))


(defmain [&rest args]
  (print a-system (documentation a-system) :sep "\n"))
