(import re)

(import sympy)


(defclass Poly [sympy.Poly]
  (defn --str-- [self]
    "Replace asterisk style (**) power operator with caret style (^)"
    (-> (string (.as-expr self)) (.replace "**" "^")))

  (defn coeff-list [self params]
    "Return coefficient list when there is no free variable"
    (setv new-poly (Poly (.subs self params) self.gen)
          free-symbols new-poly.free-symbols-in-domain)
    (when free-symbols
      (raise (ValueError (% "There are free symbols in polynomial: %s"
                         free-symbols))))
    (list (map float (.as-list new-poly))))

  (setv --repr-- --str--))


(defn str-to-poly [poly-str]
  "Turn a string polynomial into a Poly object"
  (defn unknown-in-poly? [unknown-str]
    (setv pattern (+ ".*\\b" unknown-str "\\b.*"))
    (re.match pattern poly-str))
  (setv unknown-char (if (unknown-in-poly? "z") "z" "s"))
  (setv unknown (sympy.Symbol unknown-char))
  (Poly poly-str unknown))
