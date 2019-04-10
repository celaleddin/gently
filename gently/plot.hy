(import [math [ceil]])
(import [time [sleep]])

(import [matplotlib [pyplot :as plt]])

(setv *max-row-count* 3)


(defn plot-together [&rest things]
  "Plot things into one subplot"
  (lfor thing things (.plot plt #* thing))
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
    (.plot plt #* thing)
    (sleep 0))
  (.show plt))


(defn plot-list [thing-list]
  (plot-separately #* thing-list))


(defmacro/g! bode-plot [system]
  `(do
     (.bode-plot control (.evaluate (substitute ~system)))
     (.show control.freqplot.plt)))

(defmacro/g! nyquist-plot [system]
  `(do
     (.nyquist-plot control (.evaluate (substitute ~system)))
     (.show control.freqplot.plt)))


(defmacro/g! root-locus-plot [system]
  `(do
     (import [control.rlocus [pylab :as ~g!pylab]])
     (.root-locus control (.evaluate (substitute ~system)))
     (.show ~g!pylab)))


(defmacro/g! pole-zero-plot [system]
  `(do
     (import [matplotlib [pyplot :as ~g!plt]])
     (control.pzmap (.evaluate (substitute ~system)))
     (.show ~g!plt)))


(defmacro/g! poles [system] `(control.pole (.evaluate (substitute ~system))))
(defmacro/g! zeros [system] `(control.zero (.evaluate (substitute ~system))))
