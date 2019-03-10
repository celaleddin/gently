(import [gently.utils [expr->string
                       join-names]])
(import [gently.controls [TransferFunction
                          EvaluatedTransferFunction]])


(defmacro define-transfer-function [system-name &rest system-args]
  "Define a transfer function"
  (if (string? (first system-args))
      (setv docstring (first system-args)
            system-args (rest system-args))
      (setv docstring None))
  (setv arg-dict (dfor (, k #* v) system-args
                       [k (join-names #* (map expr->string v))]))
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


(defmacro %tf-operator [op-name arg-name form &optional docstring]
  "Define a form as a transfer function operation"
  `(defn ~op-name [~arg-name]
     ~docstring
     (unless (isinstance ~arg-name (, TransferFunction
                                      EvaluatedTransferFunction))
       (raise (ValueError "Argument must be a transfer function.")))
     ~form))

(%tf-operator numerator tf (.get-num tf)
              "Get the numerator of transfer function")
(%tf-operator denominator tf (.get-den tf)
              "Get the denominator of transfer function")
(%tf-operator sampling-period tf (.get-dt tf)
              "Get the sampling period of transfer function")


(defmacro define [symbol value &optional docstring]
  "Define a variable"
  `(do
     (import gently.python)
     (require gently.utils)
     (setv ~symbol (gently.python.variable ~value))
     ~(when docstring
        `(gently.utils.set-docstring ~symbol ~docstring))))


(defmacro documentation [symbol]
  "Get the documentation of symbol"
  `(do
     (require gently.utils)
     (gently.utils.get-docstring ~symbol)))


(defmacro/g! doc [macro-symbol]
  "Get the documentation of macro `macro-symbol`"
  (setv macro-name (.replace (name macro-symbol) "-" "_"))
  `(do
     (require [hy.core.macros [doc :as ~g!hy-doc]])
     (~g!hy-doc ~(HySymbol macro-name))))


(defmacro evaluate [system &optional [values '()]]
  "Evaluate a system using given `values`"
  (setv vals (dfor (, k v) (partition values) [(name k) v]))
  `(do
     (require [gently.utils [local-numbers]])
     (.substitute ~system {#** (local-numbers) #** ~vals})))


(deftag tf [sys]
  "Define a transfer function in a short way, like `#tf(1/s)`"
  (with-gensyms [tf expr->string s py-eval]
   `(do
      (import [gently.controls [EvaluatedTransferFunction :as ~tf]]
              [gently.utils [expr->string :as ~expr->string]]
              [builtins [eval :as ~py-eval]])
      (require [gently.utils [local-numbers]])
      (setv ~s (~tf [1 0] [1]))
      (~py-eval (.replace (~expr->string '~sys) "^" "**")
       #_:globals (local-numbers) #_:locals {"s" ~s}))))


(defmacro connect [&rest paths]
  "Connect systems with `>` as series and with `^` as feedback"
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

(setv (get --macros-- "o") (get --macros-- "connect"))
