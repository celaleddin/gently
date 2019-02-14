(import [gently.utils [join-names]])

(defmacro coefficients [&rest polynomial]
  (defn symbol-in-polynomial? [symbol]
    (any (map (fn [s] (try (in symbol s)
                           (except [TypeError] False)))
              polynomial)))
  (setv unknown (if (symbol-in-polynomial? 's) "s"
                    (symbol-in-polynomial? 'z) "z"
                    "x"))
  (setv unknown-symbol (gensym unknown))
  `(do
     (import [sympy [Poly Symbol]])
     (setv ~unknown-symbol (Symbol ~unknown))
     (list (map int (.all_coeffs (Poly ~(join-names #* polynomial)
                                       ~unknown-symbol))))))
