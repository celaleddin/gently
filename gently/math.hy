(import [gently.utils [join-names]])


(defmacro coeffs [&rest poly]
  (defn symbol-in-poly? [symbol]
    (any (map (fn [s] (try (in symbol s)
                           (except [TypeError] False)))
              poly)))
  (setv unknown (if (symbol-in-poly? 's) "s"
                    (symbol-in-poly? 'z) "z"
                    "x"))
  (setv unknown-symbol (gensym unknown))
  `(do
     (import [sympy [Poly Symbol]]
             [gently.utils [only-number-values]])
     (setv ~unknown-symbol (Symbol ~unknown))
     (setv numbers-dict (only-number-values (locals)))
     (list (map (fn [c] (int (.evalf c :subs numbers-dict)))
                (.all_coeffs (Poly ~(join-names #* poly)
                                   ~unknown-symbol))))))
