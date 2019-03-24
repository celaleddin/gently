(import [control.timeresp [np]])

(require [hy.extra.anaphoric [ap-if]])


(defn define-input-signal [duration signal-conditioner]
  (setv time-data (.linspace np 0 duration (* 100 duration)))
  (, time-data
     (np.array (list (map signal-conditioner time-data)))))


(deftag step [form]
  "Return a tuple representing step input.
  Example: #step(start-time end-time amplitude)"
  (setv start (ap-if (first form) it 0)
        end (ap-if (second form) it 10)
        amplitude (try (get form 2) (except [IndexError] 1)))
  `(define-input-signal
     :duration ~end
     :signal-conditioner (fn [t]
                           (if (<= t ~start)
                               0
                               ~amplitude))))


(deftag ramp [form]
  "Return a tuple representing ramp input.
  Example: #ramp(start-time end-time slope)"
  (setv start (ap-if (first form) it 0)
        end (ap-if (second form) it 10)
        slope (try (get form 2) (except [IndexError] 1)))
  `(define-input-signal
     :duration ~end
     :signal-conditioner (fn [t]
                           (if (<= t ~start)
                               0
                               (* ~slope
                                  (- t ~start))))))
