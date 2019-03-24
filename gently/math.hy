(import re)
(import math)

(import sympy)


(setv pi math.pi)
(setv tau (* 2 pi))


(defclass Poly [sympy.Poly]
  (defn --str-- [self]
    "Replace asterisk style (**) power operator with caret style (^)"
    (-> (string (.as-expr self)) (.replace "**" "^")))

  (defn substitute [self values]
    "Substitute free symbols of the polynomial using the dict `values`"
    (Poly (.subs self values) self.gen))

  (defn coeff-list [self]
    "Return coefficient list if there is no free symbol,
     else raise an exception"
    (list (map (fn [exp]
                 (if exp.is-Integer (int exp)
                     exp.is-Float (float exp)
                     (raise (ValueError "Unknown expression."))))
               (.as-list self))))

  (defn --mul-- [self other]
    (.ensure-same-symbols self other)
    (Poly (sympy.Poly.--mul-- self other) self.gen))

  (defn --div-- [self other]
    (.ensure-same-symbols self other)
    (Poly (sympy.Poly.--div-- self other) self.gen))

  (defn ensure-same-symbols [self other]
    (unless (= self.gen other.gen)
      (raise (ValueError "Polynomial unknowns must be the same"))))

  (setv --repr-- --str--))


(defn string->poly [poly-str &optional [vals {}]]
  "Turn a string polynomial into a Poly object by substituting `vals`"
  (defn unknown-in-poly? [unknown-str]
    (setv pattern (+ ".*\\b" unknown-str "\\b.*"))
    (re.match pattern poly-str))
  (setv unknown-char (if (unknown-in-poly? "s") "s"
                         (unknown-in-poly? "z") "z"
                         "s"))
  (setv unknown (sympy.Symbol unknown-char))
  (.substitute (Poly poly-str unknown) vals))


(defn coeff-list->poly [coeff-list symbol]
  "Turn a coefficient list into a Poly object"
  (Poly coeff-list (sympy.Symbol (name symbol))))
