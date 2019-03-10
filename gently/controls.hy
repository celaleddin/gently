(import re)

(import [sympy [Poly Symbol]])
(import [control [TransferFunction :as EvaluatedTransferFunction]])

(import [gently.math [string->poly coeff-list->poly
                      poly-multiply poly-divide]]
        [gently.utils [print-to-string]])

(setv *tf-print-margin* 2)


(defn evaluated-tf/to-string [self]
  "Add left margin and replace space style multiplications
   with asterisk style (*)"
  (setv default-str (.--str-- self))
  (setv str-with-margin (.replace default-str
                                  "\n"
                                  (+ "\n" (* " " *tf-print-margin*))))
  (re.sub "\\b \\b" "*" str-with-margin))

(defmacro coeff-list->poly/method [attr]
  `(fn [self] (coeff-list->poly (get (getattr self ~(name attr)) 0 0)
                                (if self.dt 'z 's))))
(setv ETF EvaluatedTransferFunction
      ETF.--repr-- evaluated-tf/to-string
      ETF.evaluate (fn [self] self)
      ETF.get-num (coeff-list->poly/method num)
      ETF.get-den (coeff-list->poly/method den)
      ETF.get-dt (fn [self] self.dt)
      ETF.substitute (fn [self &optional [params {}]] self))


(defclass TransferFunction []
  """Transfer function representation layer between
     the language macros and control package."""
  (defn --init-- [self num den &optional dt &kwonly [vals {}]]
    (setv self.num (if (string? num) (string->poly num vals) num)
          self.den (if (string? den) (string->poly den vals) den)
          self.dt (if dt (float dt) None)))

  (defn get-num [self] self.num)
  (defn get-den [self] self.den)
  (defn get-dt [self] self.dt)

  (defn get-free-symbols [self]
    (.union self.num.free-symbols-in-domain
            self.den.free-symbols-in-domain))

  (defn substitute [self &optional [params {}]]
    (TransferFunction (.substitute self.num params)
                      (.substitute self.den params)
                      self.dt))

  (defn evaluate [self]
    (setv free-symbols (.get-free-symbols self))
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
    (print-to-string "" num-str division-str den-str
                     :sep (+ "\n" (* " " *tf-print-margin*))))

  (setv --repr-- --str--))


(defmacro/g! ensure-all-dt-same [systems into]
  `(do
     (setv ~g!all-dt (list (distinct (map (fn [sys] (.get-dt sys)) ~systems))))
     (if (= 1 (len ~g!all-dt))
         (setv ~into (first ~g!all-dt))
         (raise (ValueError "All sampling periods must be same")))))


(defn series [&rest systems]
  "Connect `systems` in series"
  (ensure-all-dt-same systems dt)
  (defmacro poly-multiply-with-key [&key key]
    `(poly-multiply #* (map (fn [sys] (~key sys)) systems)))
  (setv num-multiplied (poly-multiply-with-key :key .get-num)
        den-multiplied (poly-multiply-with-key :key .get-den))
  (TransferFunction num-multiplied den-multiplied dt))


(defn feedback [forward-path &optional feedback-path feedback-sign]
  (ensure-all-dt-same [forward-path feedback-path] dt)
  )


(defn parallel-of-two [sys-1 sys-2]
  "Connect two systems in parallel"
  (ensure-all-dt-same [sys-1 sys-2] dt)
  (TransferFunction (+ (poly-multiply (.get-num sys-1) (.get-den sys-2))
                       (poly-multiply (.get-num sys-2) (.get-den sys-1)))
                    (poly-multiply (.get-den sys-1) (.get-den sys-2))
                    dt))

(defn parallel [&rest systems]
  "Connect `systems` in parallel"
  (reduce parallel-of-two systems))
