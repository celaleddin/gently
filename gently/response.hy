(import control)


(defn step-response [system]
  (control.step-response (.evaluate system)))


(defn input-response [input system]
  (control.forced-response (.evaluate system) #* input))
