(require [hy.extra.anaphoric [ap-if]])


(deftag step [form]
  (setv amplitude (ap-if (first form) it 1)
        delay (ap-if (second form) it 0)
        duration (try (get form 2) (except [IndexError] 10)))
  (with-gensyms [np]
    `(do
       (import [control.timeresp [np :as ~np]])
       (setv timeseries (.linspace ~np 0 ~duration 250))
       (,
        timeseries
        (lfor t timeseries
              (if (<= t ~delay) 0 ~amplitude))))))
