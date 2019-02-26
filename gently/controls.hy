(import re)

(import [sympy [Poly Symbol]])
(import [control [TransferFunction :as TF]])

(import [gently.math [str-to-poly]]
        [gently.utils [print-to-str]])

(setv *tf-print-margin* 2)


(defclass EvaluatedTransferFunction [TF]
  (defn --str-- [self]
    "Add left margin and replace space style multiplications with asterisk style (*)"
    (setv default-str (.--str-- (super)))
    (setv str-with-margin (.replace default-str
                                    "\n" (+ "\n" (* " " *tf-print-margin*))))
    (re.sub "\\b \\b" "*" str-with-margin))

  (setv --repr-- --str--))


(defclass TransferFunction []
  """
  Transfer function representation layer between
  the language macros and control package.
  """
  (defn --init-- [self num den &optional dt]
    (setv self.num (str-to-poly num)
          self.den (str-to-poly den)
          self.dt (if dt (float dt) 0.0)))

  (defn get-num [self] self.num)
  (defn get-den [self] self.den)
  (defn get-dt [self] self.dt)

  (defn evaluate [self params]
    (setv args [(.coeff-list self.num params)
                (.coeff-list self.den params)])
    (when self.dt
      (.append args self.dt))
    (EvaluatedTransferFunction #* args))

  (defn --str-- [self]
    (setv num-str (string self.num)
          den-str (string self.den)
          width (max (len num-str) (len den-str)))
    (setv num-str (.center num-str width)
          den-str (.center den-str width)
          division-str (* "-" width))
    (print-to-str "" num-str division-str den-str
                  :sep (+ "\n" (* " " *tf-print-margin*))))

  (setv --repr-- --str--))
