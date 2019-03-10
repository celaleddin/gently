(import re)

(import sympy)


(defclass Poly [sympy.Poly]
  (defn --str-- [self]
    "Replace asterisk style (**) power operator with caret style (^)"
    (-> (string (.as-expr self)) (.replace "**" "^")))

  (defn substitute [self params]
    (Poly (.subs self params) self.gen))

  (defn coeff-list [self]
    """Return coefficient list if there is no free symbol,
       else raise an exception"""
    (list (map (fn [exp]
                 (if exp.is-Integer (int exp)
                     exp.is-Float (float exp)
                     (raise (ValueError "Unknown expression."))))
               (.as-list self))))

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
  (Poly coeff-list (sympy.Symbol (name symbol))))


(defn poly-multiply [&rest polys]
  (setv poly-var (getattr (first polys) "gen"))
  (Poly (* #* polys) poly-var))

(defn poly-divide [&rest polys]
  (setv poly-var (getattr (first polys) "gen"))
  (Poly (/ #* polys) poly-var))
