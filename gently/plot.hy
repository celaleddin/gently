(import [math [ceil]])

(import [matplotlib [pyplot :as plotter]])

(setv *max-row-count* 3)


(defmacro/g! plot-together [&rest forms]
  "Plot things into one subplot"

   "Example, plot input and input response together:
   (plot-together
     (forced-response yet-another-one input)
     input)
  "
  `(do
     (import [gently.plot [plotter :as ~g!plt]])
     ~(lfor form forms `(.plot ~g!plt #* ~form))
     (.show ~g!plt)))


(defmacro/g! plot-separately [&rest forms]
  "Plot things in seperate subplots

   Example, plot many system responses separately:
   (plot-separately
     (step-response a-system)
     (step-response another-system)
     (together  ;; forms in `together` will be plotted together
       (forced-response yet-another-one input)
       input))
  "
  (setv enumerated-forms (list (enumerate forms :start 1)))
  (setv together-forms (dfor (, i form) enumerated-forms
                             :if (= (first form) 'together)
                             [i (list (rest form))]))
  (setv plot-count (len forms)
        column-count (ceil (/ plot-count *max-row-count*))
        row-count (if (= column-count 1) plot-count *max-row-count*))
  `(do
     (import [gently.plot [plotter :as ~g!plt]]
             [time [sleep :as ~g!sleep]])
     (.figure ~g!plt 1)
     ~(lfor (, i form) enumerated-forms
            `(do
               (.subplot ~g!plt ~row-count ~column-count ~i)
               ~(if (in i together-forms)
                    `(do
                       ~(lfor form (get together-forms i)
                              `(.plot ~g!plt #* ~form)))
                    `(.plot ~g!plt #* ~form))
               (~g!sleep 0)))
     (.show ~g!plt)))
