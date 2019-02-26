(import [gently.utils [join-names]])


(defmacro define-transfer-function [system-name &rest args]
  (if (string? (first args))
      (setv docstring (first args)
            args (rest args))
      (setv docstring None))
  (setv arg-dict (dfor (, k #* v) args [k (join-names #* v)]))
  `(do
     (import gently.controls)
     (setv ~system-name (gently.controls.TransferFunction
                          ~(get arg-dict 'numerator)
                          ~(get arg-dict 'denominator)
                          ~(when (in 'sampling-period arg-dict)
                             (get arg-dict 'sampling-period))))
     ~(when docstring
        `(do
           (require gently.utils)
           (gently.utils.set-docstring ~system-name ~docstring)))
     ~system-name))


(defmacro numerator [tf] `(.get-num ~tf))
(defmacro denominator [tf] `(.get-den ~tf))
(defmacro sampling-period [tf] `(.get-dt ~tf))


(defmacro define [symbol value &optional docstring]
  `(do
     (import gently.python)
     (require gently.utils)
     (setv ~symbol (gently.python.variable ~value))
     ~(when docstring
        `(gently.utils.set-docstring ~symbol ~docstring))))


(defmacro documentation [symbol]
  `(do
     (require gently.utils)
     (gently.utils.get-docstring ~symbol)))
