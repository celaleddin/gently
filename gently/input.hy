(import [control.timeresp [np]])
(import [gently.math [tau]])

(require [hy.extra.anaphoric [ap-if]])


(setv *default-start-time* 0)
(setv *default-end-time* 10)
(setv *steps-per-unit-duration* 100)


(defn define-input-signal [duration signal-conditioner]
  (setv time-data (.linspace np 0 duration (* *steps-per-unit-duration*
                                              duration)))
  (, time-data
     (np.array (list (map signal-conditioner time-data)))))


(defmacro include-default-start/end-time [form-name]
  `(setv start (ap-if (first ~form-name) it *default-start-time*)
         end (ap-if (second ~form-name) it *default-end-time*)))


(deftag step [form]
  "Return a tuple representing step input.
  Example: #step(start-time end-time amplitude)"
  (include-default-start/end-time form)
  (setv amplitude (try (get form 2) (except [IndexError] 1)))
  `(define-input-signal
     :duration ~end
     :signal-conditioner (fn [t]
                           (if (<= t ~start)
                               0
                               ~amplitude))))


(deftag ramp [form]
  "Return a tuple representing ramp input.
  Example: #ramp(start-time end-time slope)"
  (include-default-start/end-time form)
  (setv slope (try (get form 2) (except [IndexError] 1)))
  `(define-input-signal
     :duration ~end
     :signal-conditioner (fn [t]
                           (if (<= t ~start)
                               0
                               (* ~slope
                                  (- t ~start))))))


(deftag parabola [form]
  (include-default-start/end-time form)
  `(define-input-signal
     :duration ~end
     :signal-conditioner (fn [t]
                           (setv value (- t ~start))
                           (if (<= t ~start)
                               0
                               (* value value)))))


(deftag sine [form]
  (setv start (ap-if (first form) it 0)
        end (ap-if (second form) it tau))
  (with-gensyms [math]
    `(do
       (import [math :as ~math])
       (define-input-signal
         :duration ~end
         :signal-conditioner (fn [t]
                               (setv value (- t ~start))
                               (if (<= t ~start)
                                   0
                                   (.sin ~math value)))))))
