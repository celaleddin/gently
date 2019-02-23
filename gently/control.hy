(import [gently.math [coeffs]])

(defclass TransferFunction []
  (defn --init-- [self num den &optional dt]
    (setv self.num (coeffs num)
          self.den (coeffs den))
    (when dt
      (setv self.dt (float dt)))))
