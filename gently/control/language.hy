(defmacro define-transfer-function [system-name &rest args]
  (setv arg-dict (dfor (, k #* v) args [k v]))
  `(do
     (import [control [tf]] [sympy [Symbol]])
     (require [gently.math.polynomials [coefficients]])
     (setv ~system-name (tf (coefficients ~@(get arg-dict :numerator))
                            (coefficients ~@(get arg-dict :denominator))
                            ~(when (in :sampling-period arg-dict)
                               (first (get arg-dict :sampling-period)))))
     (setattr ~system-name "doc" ~@(get arg-dict :documentation))
     ~system-name))

(defmacro documentation [object]
  `(. ~object doc))
