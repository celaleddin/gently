(import gently)


(defn validate-tf [tf-data]
  (unless (and (in :numerator tf-data)
               (in :denominator tf-data))
    (raise (ValueError "Both :numerator and :denominator must be given."))))


(defmacro define-transfer-function [system-name &rest args]
  (setv arg-dict (dfor (, k #* v) args [k v]))
  (validate-tf arg-dict)
  `(do
     (import control)
     (require gently.math gently.utils)
     (setv ~system-name (control.tf (gently.math.coeffs ~@(get arg-dict :numerator))
                                    (gently.math.coeffs ~@(get arg-dict :denominator))
                                    ~(when (in :sampling-period arg-dict)
                                       (first (get arg-dict :sampling-period)))))
     ~(when (in :documentation arg-dict)
        `(gently.utils.attach-docstring ~system-name ~@(get arg-dict :documentation)))
     ~system-name))

(defmacro define [symbol value &optional docstring]
  `(do
     (require gently.utils)
     (setv ~symbol ~value)
     ~(when docstring
        `(gently.utils.attach-docstring ~symbol ~docstring))))

(defmacro/g! documentation [symbol]
  `(do
     (setv ~g!key (gently.utils.join-names (id ~symbol) ~symbol))
     (if (in ~g!key gently.utils.*docstring-dict*)
         (get gently.utils.*docstring-dict* ~g!key)
         (% "No documentation found for symbol '%s'" (name '~symbol)))))

