(require [hy.extra.anaphoric [ap-if]])

(import [gently.utils [expr->string
                       join-names]])
(import [gently.controls [TransferFunction
                          EvaluatedTransferFunction]])


(defmacro define-transfer-function [system-name &rest args]
  (if (string? (first args))
      (setv docstring (first args)
            args (rest args))
      (setv docstring None))
  (setv arg-dict (dfor (, k #* v) args [k (join-names #* v)]))
  `(do
     (import gently.controls)
     (require gently.utils)
     (setv ~system-name (gently.controls.TransferFunction
                          ~(get arg-dict 'numerator)
                          ~(get arg-dict 'denominator)
                          ~(when (in 'sampling-period arg-dict)
                             (get arg-dict 'sampling-period))
                          :vals (gently.utils.local-numbers)))
     ~(when docstring
        `(gently.utils.set-docstring ~system-name ~docstring))
     ~system-name))


(defmacro tf-operator [op-name arg-name form]
  `(defn ~op-name [~arg-name]
     (unless (isinstance ~arg-name (, TransferFunction
                                      EvaluatedTransferFunction))
       (raise (ValueError "Argument must be a transfer function.")))
     ~form))

(tf-operator numerator tf (.get-num tf))
(tf-operator denominator tf (.get-den tf))
(tf-operator sampling-period tf (.get-dt tf))

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


(deftag . [sys-and-vals]
  (setv sys (first sys-and-vals)
        vals (ap-if (second sys-and-vals) it [])
        values (dfor (, k v) (partition vals) [(name k) v]))
  `(do
     (require [gently.utils [local-numbers]])
     (.substitute ~sys {#** (local-numbers) #** ~values})))


(deftag tf [sys]
  (with-gensyms [tf expr->string s py-eval]
   `(do
      (import [gently.controls [EvaluatedTransferFunction :as ~tf]]
              [gently.utils [expr->string :as ~expr->string]]
              [builtins [eval :as ~py-eval]])
      (require [gently.utils [local-numbers]])
      (setv ~s (~tf [1 0] [1]))
      (~py-eval (.replace (~expr->string '~sys) "^" "**")
       #_:globals (local-numbers) #_:locals {"s" ~s}))))


(defmacro o [&rest paths]
  (setv forward-paths []
        feedback-path []
        lrest (fn [coll] (list (rest coll)))
        lreversed (fn [coll] (list (reversed coll))))
  (for [path paths]
    (if (= '> (first path)) (.append forward-paths (lrest path))
        (in (first path) '(^ ^+ ^-)) (setv feedback-path (lrest path)
                                           feedback-type (first path))
        (continue)))
  (setv import-statement `(import [control :as c])
        forward-result `(c.parallel
                          ~@(lfor systems forward-paths
                                  `(c.series #* ~systems))))
  `(do
     ~import-statement
     ~(if feedback-path
          `(c.feedback
             ~forward-result
             (c.series #* ~(lreversed feedback-path))
             ~(if (in feedback-type '(^ ^-)) -1 +1))
          forward-result)))
