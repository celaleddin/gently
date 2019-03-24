(import re)

(import [control [TransferFunction :as EvaluatedTransferFunction]])

(import [gently.math [string->poly coeff-list->poly]]
        [gently.utils [print-to-string expr->string]])

(setv *tf-print-margin* 2)


(defn evaluated-tf/to-string [self]
  "Add left margin and replace space style multiplications
   with asterisk style (*)"
  (setv default-str (.--str-- self))
  (setv str-with-margin (.replace default-str
                                  "\n"
                                  (+ "\n" (* " " *tf-print-margin*))))
  (re.sub "\\b \\b" "*" str-with-margin))

(defmacro coeff-list->poly/method [attr]
  `(fn [self] (coeff-list->poly (get (getattr self ~(name attr)) 0 0)
                                (if self.dt 'z 's))))
(setv ETF EvaluatedTransferFunction
      ETF.--repr-- evaluated-tf/to-string
      ETF.evaluate (fn [self] self)
      ETF.get-num (coeff-list->poly/method num)
      ETF.get-den (coeff-list->poly/method den)
      ETF.get-dt (fn [self] self.dt)
      ETF.substitute (fn [self &optional [params {}]] self))


(defclass TransferFunction []
  "Transfer function representation layer between the language
   macros and control package."
  (defn --init-- [self num den &optional dt]
    (setv self.num (if (string? num) (string->poly num) num)
          self.den (if (string? den) (string->poly den) den)
          self.dt (if dt (float dt) None)))

  (defn get-num [self] self.num)
  (defn get-den [self] self.den)
  (defn get-dt [self] self.dt)

  (defn get-free-symbols [self]
    "Return free symbols of the transfer function"
    (.union self.num.free-symbols-in-domain
            self.den.free-symbols-in-domain))

  (defn substitute [self &optional [values {}]]
    "Substitute free symbols of the transfer function with `values`"
    (TransferFunction (.substitute self.num values)
                      (.substitute self.den values)
                      self.dt))

  (defn evaluate [self]
    "Evaluate the transfer function"
    (setv free-symbols (.get-free-symbols self))
    (when free-symbols
      (raise (ValueError (+ "There must be no free symbols "
                            "in transfer functions to evaluate them. "
                            "Free symbols: " (string free-symbols)))))
    (EvaluatedTransferFunction (.coeff-list self.num)
                               (.coeff-list self.den)
                               self.dt))

  (defn --str-- [self]
    (setv num-str (string self.num)
          den-str (string self.den)
          width (max (len num-str) (len den-str)))
    (setv num-str (.center num-str width)
          den-str (.center den-str width)
          division-str (* "-" width))
    (setv seperator (+ "\n" (* " " *tf-print-margin*)))
    (setv num-and-den (print-to-string "" num-str division-str den-str
                                       :sep seperator))
    (if self.dt
        (print-to-string "" (+ "dt = " (string self.dt))
                         :sep seperator :initial num-and-den)
        num-and-den))
  (setv --repr-- --str--))


(defn numerator [tf]
  "Get the numerator of transfer function `tf`" (.get-num tf))
(defn denominator [tf]
  "Get the denominator of transfer function `tf`" (.get-den tf))
(defn sampling-period [tf]
  "Get the sampling period of transfer function `tf`" (.get-dt tf))


;;;; Transfer function operations

(defn ensure-same-dt [sys-1 sys-2]
  "Ensure `sys-1` and `sys-2` have the same sampling period"
  (unless (= (sampling-period sys-1) (sampling-period sys-2))
    (raise (ValueError "Sampling periods must be the same"))))

(defn tf-multiply [sys-1 sys-2]
  "Multiply transfer functions"
  (ensure-same-dt sys-1 sys-2)
  (TransferFunction (* (numerator sys-1) (numerator sys-2))
                    (* (denominator sys-1) (denominator sys-2))
                    (sampling-period sys-1)))

(defn tf-divide [sys-1 sys-2]
  "Divide transfer functions"
  (ensure-same-dt sys-1 sys-2)
  (TransferFunction (* (numerator sys-1) (denominator sys-2))
                    (* (numerator sys-2) (denominator sys-1))
                    (sampling-period sys-1)))

(defn tf-add [sys-1 sys-2]
  "Add transfer functions"
  (ensure-same-dt sys-1 sys-2)
  (TransferFunction (+ (* (numerator sys-1) (denominator sys-2))
                       (* (numerator sys-2) (denominator sys-1)))
                    (* (denominator sys-1) (denominator sys-2))
                    (sampling-period sys-1)))

(defn tf-subtract [sys-1 sys-2]
  "Subtract transfer functions"
  (ensure-same-dt sys-1 sys-2)
  (TransferFunction (- (* (numerator sys-1) (denominator sys-2))
                       (* (numerator sys-2) (denominator sys-1)))
                    (* (denominator sys-1) (denominator sys-2))
                    (sampling-period sys-1)))


;;;; System interconnections

(defn series [&rest systems]
  "Connect `systems` in series"
  (reduce tf-multiply systems))

(defn feedback [forward-path &optional feedback-path [feedback-sign -]]
  "Connect `forward-path` and `feedback-path` using a feedback loop"
  (unless feedback-path
    (setv feedback-path (TransferFunction "1" "1"
                                          (sampling-period forward-path))))
  (setv feedback-operator (if (= feedback-sign +) tf-subtract
                              (= feedback-sign -) tf-add
                              (raise (ValueError
                                       "Feedback sign must be + or -"))))
  (tf-divide forward-path
             (feedback-operator
               (TransferFunction "1" "1" (sampling-period forward-path))
               (tf-multiply forward-path feedback-path))))

(defn parallel [&rest systems]
  "Connect `systems` in parallel"
  (reduce tf-add systems))


;;;; Transfer function related macros

(defmacro/g! define-transfer-function [system-name &rest system-args]
  "Define a transfer function"
  (if (string? (first system-args))
      (setv docstring (first system-args)
            system-args (rest system-args))
      (setv docstring None))
  (setv arg-dict (dfor (, k #* v) system-args
                       [k (.join " " (map expr->string v))]))
  `(do
     (import [gently.transfer-function [TransferFunction :as ~g!TF]])
     (require [gently.variable [set-documentation :as ~g!set-documentation]])
     (setv ~system-name (~g!TF
                         ~(get arg-dict 'numerator)
                         ~(get arg-dict 'denominator)
                         ~(when (in 'sampling-period arg-dict)
                            (get arg-dict 'sampling-period))))
     ~(when docstring
        `(~g!set-documentation ~system-name ~docstring))
     ~system-name))


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
       (import [gently.transfer-function [EvaluatedTransferFunction :as ~tf]]
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
  (setv import-statement `(import [gently.transfer-function :as connect])
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
