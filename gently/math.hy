(import re)

(import [sympy [Poly Symbol]])

(defn coeffs [poly-str]
  (defn unknown-in-poly? [unknown-str]
    (setv pattern (+ ".*\\b" unknown-str "\\b.*"))
    (re.match pattern poly-str))
  (setv unknown-char (if (unknown-in-poly? "s") "s"
                         (unknown-in-poly? "z") "z"
                         "any-another-string"))
  (setv unknown (Symbol unknown-char))
  (.all_coeffs (Poly poly-str unknown)))
