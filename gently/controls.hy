(import re)

(import [sympy [Poly Symbol]])
(import [control [TransferFunction :as EvaluatedTransferFunction]])

(import [gently.math [str-to-poly]]
        [gently.utils [print-to-str]])

(setv *tf-print-margin* 2)


(defn evaluated-tf-to-string [self]
  "Add left margin and replace space style multiplications
   with asterisk style (*)"
  (setv default-str (.--str-- self))
  (setv str-with-margin (.replace default-str
                                  "\n"
                                  (+ "\n" (* " " *tf-print-margin*))))
  (re.sub "\\b \\b" "*" str-with-margin))
(setv EvaluatedTransferFunction.--repr-- evaluated-tf-to-string)


(defclass TransferFunction []
  """
  Transfer function representation layer between
  the language macros and control package.
  """
  (defn --init-- [self num den &optional dt &kwonly [vals {}]]
    (setv self.num (if (string? num) (str-to-poly num vals) num)
          self.den (if (string? den) (str-to-poly den vals) den)
          self.dt (if dt (float dt) None)))

  (defn get-num [self] self.num)
  (defn get-den [self] self.den)
  (defn get-dt [self] self.dt)

  (defn evaluate-possible? [self]
    (.union self.num.free-symbols-in-domain
            self.den.free-symbols-in-domain))

  (defn substitute [self &optional [params {}]]
    (TransferFunction (.substitute self.num params)
                      (.substitute self.den params)
                      self.dt))

  (defn evaluate [self]
    (setv free-symbols (.evaluate-possible? self))
    (when free-symbols
      (raise (ValueError (+ "There must be no free symbols "
                            "in transfer functions. There are: "
                            (string free-symbols)))))
    (setv args (lfor p [self.num self.den] (.coeff-list p)))
    (when self.dt (.append args self.dt))
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
