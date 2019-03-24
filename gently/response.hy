(import control)

(require [gently.input [step]])


(defmacro/g! input-response [input system]
  `(do
     (import [control :as ~g!control])
     (.forced-response ~g!control (.evaluate (substitute ~system)) #* ~input)))


(defmacro/g! step-response [system &optional [start 0] [end 10]]
  `(input-response #step(~start ~end) ~system))
