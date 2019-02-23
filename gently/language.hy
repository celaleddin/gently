(import [gently.utils [join-names]])

(defmacro define-transfer-function [system-name &rest args]
  (if (string? (first args))
      (setv docstring (first args)
            args (rest args))
      (setv docstring None))
  (setv arg-dict (dfor (, k #* v) args [k (join-names #* v)]))
  `(do
     (import gently.control)
     (setv ~system-name (gently.control.TransferFunction
                          ~(get arg-dict :numerator)
                          ~(get arg-dict :denominator)
                          ~(when (in :sampling-period arg-dict)
                             (get arg-dict :sampling-period))))
     ~(when docstring `(setattr ~system-name "**doc**" ~docstring))
     ~system-name))

(defmacro define [symbol value &optional docstring]
  `(do
     (import gently.python)
     (setv ~symbol (gently.python.variable ~value))
     ~(when docstring
        `(setattr ~symbol "**doc**" ~docstring))))

(defmacro documentation [symbol]
  `(getattr ~symbol "**doc**"
            (% "No documentation found for symbol '%s'" (name '~symbol))))
