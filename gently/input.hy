(import [control.timeresp [np]])

(require [hy.extra.anaphoric [ap-if]])


(defn make-input [duration signal-conditioner &optional previous-aware?]
  (setv time-data (.linspace np 0 duration (* 100 duration)))
  (if previous-aware?
      (setv previous-value 0
            conditioner (fn [t]
                          (nonlocal previous-value)
                          (setv value (signal-conditioner t previous-value)
                                previous-value value)
                          value))
      (setv conditioner signal-conditioner))
  (, time-data
     (np.array (list (map conditioner time-data)))))


(deftag step [form]
  "Return a tuple representing step input.
  Example: #step(start-time end-time amplitude)"
  (setv start (ap-if (first form) it 0)
        end (ap-if (second form) it 10)
        amplitude (try (get form 2) (except [IndexError] 1)))
  (with-gensyms [np make-input]
    `(do
       (import [control.timeresp [np :as ~np]])
       (import [gently.input [make-input :as ~make-input]])
       (make-input
         :duration ~end
         :signal-conditioner (fn [t]
                               (if (<= t ~start)
                                   0
                                   ~amplitude))))))
