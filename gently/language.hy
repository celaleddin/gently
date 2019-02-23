(defn validate-tf [tf-data]
  (unless (and (in :numerator tf-data)
               (in :denominator tf-data))
    (raise (ValueError "Both :numerator and :denominator must be given."))))


(defmacro define-transfer-function [system-name &rest args]
  (setv arg-dict (dfor (, k #* v) args [k v]))
  (validate-tf arg-dict)
  `(do
     (import control)
     (require gently.math)
     (setv ~system-name (control.tf (gently.math.coeffs ~@(get arg-dict :numerator))
                                    (gently.math.coeffs ~@(get arg-dict :denominator))
                                    ~(when (in :sampling-period arg-dict)
                                       (first (get arg-dict :sampling-period)))))
     ~(when (in :documentation arg-dict)
        `(setattr ~system-name "**doc**" ~@(get arg-dict :documentation)))
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

