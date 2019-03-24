(require [hy.extra.anaphoric [ap-if]])


(deftag step [form]
  "Return a tuple representing step input.
  Example: #step(start-time end-time amplitude)"
  (setv start (ap-if (first form) it 0)
        end (ap-if (second form) it 10)
        amplitude (try (get form 2) (except [IndexError] 1)))
  (with-gensyms [np]
    `(do
       (import [control.timeresp [np :as ~np]])
       (setv timeseries (.linspace ~np 0 ~end ~(* 100 (- end start))))
       (,
        timeseries
        (lfor t timeseries
              (if (<= t ~start) 0 ~amplitude))))))
