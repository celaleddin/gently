(import [gently.utils [expr->string
                       join-names]])


(defmacro define-transfer-function [system-name &rest args]
  (if (string? (first args))
      (setv docstring (first args)
            args (rest args))
      (setv docstring None))
  (setv arg-dict (dfor (, k #* v) args
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


(defmacro/g! step-response [sys &optional [symbol-vars []]]
  (setv symbol-dict (dfor (, k v) (partition symbol-vars)
                          [(name k) v]))
  `(do
     (import [control [step_response :as ~g!step-response]]
             [matplotlib [pyplot :as ~g!plt]])
     (setv ~g!system (.substitute ~sys ~symbol-dict))
     (print ~g!system)
     (setv (, ~g!time ~g!response)
           (~g!step_response (.evaluate ~g!system)))
     (.plot ~g!plt ~g!time ~g!response)
     (.show ~g!plt)))


(deftag . [sys-and-vals]
  (setv (, sys #* vals) sys-and-vals
        vals (dfor (, k v) (.items (if vals (first vals) {}))
                   [(name k) v]))
  `(do
     (require [gently.utils [local-numbers]])
     (.substitute ~sys (dict #** ~vals #** (local-numbers)))))


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
