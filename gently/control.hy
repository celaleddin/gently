(import [sympy [Poly Symbol]])

(import [gently.math [str-to-poly poly-to-str]]
        [gently.utils [print-to-str]])

(defclass TransferFunction []
  """
  Transfer function representation layer between
  the language macros and control package.
  """
  (defn --init-- [self num den &optional dt]
    (setv self.num (str-to-poly num)
          self.den (str-to-poly den))
    (when dt
      (setv self.dt (float dt))))

  (defn num-as-str [self] (poly-to-str self.num))
  (defn den-as-str [self] (poly-to-str self.den))
  (defn dt-as-str [self]
    (if (hasattr self "dt")
        (string self.dt)
        "The system is continuous."))

  (defn num-coeffs [self] (.as-list self.num))
  (defn den-coeffs [self] (.as-list self.den))

  (defn as-str [self]
    (setv num-str (.num-as-str self)
          den-str (.den-as-str self)
          str-size (max (len num-str) (len den-str))
          width (+ 4 str-size))
    (setv num-str (.center num-str width)
          den-str (.center den-str width)
          division-str (.center (* "-" str-size) width))
    (print-to-str "" num-str division-str den-str :sep "\n"))

  (defn --str-- [self] (.as-str self))
  (setv --repr-- --str--))
