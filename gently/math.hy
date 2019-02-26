(import re)

(import sympy)

(defclass Poly [sympy.Poly]
  (defn --str-- [self]
    "Replace asterisk style (**) power operator with caret style (^)"
    (-> (string (.as-expr self)) (.replace "**" "^")))

  (defn int-coeff-list [self]
    (list (map int (.as-list self))))

  (setv --repr-- --str--))

(defn str-to-poly [poly-str]
  "Turn a string polynomial into a Poly object"
  (defn unknown-in-poly? [unknown-str]
    (setv pattern (+ ".*\\b" unknown-str "\\b.*"))
    (re.match pattern poly-str))
  (setv unknown-char (if (unknown-in-poly? "s") "s"
                         (unknown-in-poly? "z") "z"
                         "any-another-string"))
  (setv unknown (sympy.Symbol unknown-char))
  (Poly poly-str unknown))
