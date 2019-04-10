(require [gently.input [step]])


(defmacro/g! input-response [input system]
  `(->
     (.forced-response control (.evaluate (substitute ~system)) #* ~input)
     (cut None 2)))


(defmacro/g! step-response [system &optional [start 0] [end 10]]
  `(input-response #step(~start ~end) ~system))
