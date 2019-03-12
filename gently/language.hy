(import [gently.utils [expr->string]])
(import [gently.controls [TransferFunction
                          EvaluatedTransferFunction
                          numerator
                          denominator
                          sampling-period]])


(defmacro define-transfer-function [system-name &rest system-args]
  "Define a transfer function"
  (if (string? (first system-args))
      (setv docstring (first system-args)
            system-args (rest system-args))
      (setv docstring None))
  (setv arg-dict (dfor (, k #* v) system-args
                       [k (.join " " (map expr->string v))]))
  `(do
     (import gently.controls)
     (require gently.utils)
     (setv ~system-name (gently.controls.TransferFunction
                          ~(get arg-dict 'numerator)
                          ~(get arg-dict 'denominator)
                          ~(when (in 'sampling-period arg-dict)
                             (get arg-dict 'sampling-period))))
     ~(when docstring
        `(gently.utils.set-docstring ~system-name ~docstring))
     ~system-name))


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


(defmacro/g! substitute [system &optional [values '()]]
  "Substitute free symbols of `system` with `values`
   Example: (substitute a-system (a 1 b 2 c 3))"
  (setv vals (dfor (, k v) (partition values) [(name k) v]))
  `(do
     (require [gently.utils [local-numbers :as ~g!local-numbers]])
     (.substitute ~system {#** (~g!local-numbers) #** ~vals})))


(deftag tf [sys]
  "Define a transfer function in a short way, like `#tf(1/s)`"
  (with-gensyms [tf expr->string s py-eval local-numbers]
   `(do
      (import [gently.controls [EvaluatedTransferFunction :as ~tf]]
              [gently.utils [expr->string :as ~expr->string]]
              [builtins [eval :as ~py-eval]])
      (require [gently.utils [local-numbers :as ~local-numbers]])
      (setv ~s (~tf [1 0] [1]))
      (~py-eval (+ (.replace (~expr->string '~sys) "^" "**")
                   "+ 0*s") ; to turn integers to transfer functions
       #_:globals (~local-numbers) #_:locals {"s" ~s}))))


(defmacro/g! connect [&rest paths]
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
  (setv import-statement `(import [gently.controls :as connect])
        forward-result `(connect.parallel
                          ~@(lfor systems forward-paths
                                  `(connect.series #* ~systems))))
  `(do
     ~import-statement
     ~(if feedback-path
          `(connect.feedback
             ~forward-result
             (connect.series #* ~(lreversed feedback-path))
             ~(if (in feedback-type '(^ ^-)) '- '+))
          forward-result)))

(setv (get --macros-- "o") (get --macros-- "connect"))
