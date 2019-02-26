(import [sympy [Poly Symbol]])
(import [control [tf]])

(import [gently.math [str-to-poly]]
        [gently.utils [print-to-str]])

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

  (defn num-coeffs [self] (.as-list self.num))
  (defn den-coeffs [self] (.as-list self.den))

  (defn evaluate [self var-dict]
    (setv args [(self.num-coeffs) (self.den-coeffs)])
    (when self.dt
      (.append args self.dt))
    (tf #* args))

  (defn --str-- [self]
    (setv num-str (string self.num)
          den-str (string self.den)
          str-size (max (len num-str) (len den-str))
          width (+ 0 str-size))
    (setv num-str (.center num-str width)
          den-str (.center den-str width)
          division-str (.center (* "-" str-size) width))
    (print-to-str "" num-str division-str den-str :sep "\n"))

  (setv --repr-- --str--))
