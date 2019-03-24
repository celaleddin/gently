(import [math [ceil]])
(import [time [sleep]])

(import [matplotlib [pyplot :as plt]])

(setv *max-row-count* 3)


(defn filter-plot-params [params]
  "Return first two items of params"
  (cut params None 2))


(defn plot-together [&rest things]
  "Plot things into one subplot"
  (lfor thing things (.plot plt #* (filter-plot-params thing)))
  (.show plt))


(defn plot-separately [&rest things]
  "Plot things in seperate subplots"
  (setv enumerated-things (list (enumerate things :start 1)))
  (setv plot-count (len things)
        column-count (ceil (/ plot-count *max-row-count*))
        row-count (if (= column-count 1) plot-count *max-row-count*))
  (.figure plt 1)
  (for [(, i thing) enumerated-things]
    (.subplot plt row-count column-count i)
    (.plot plt #* (filter-plot-params thing))
    (sleep 0))
  (.show plt))


(defn plot-list [thing-list]
  (plot-separately #* thing-list))
