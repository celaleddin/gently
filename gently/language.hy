(import [gently.transfer_function [numerator
                                   denominator
                                   sampling-period]])
(import [gently.plot [plot-together]])
(import [gently.response [step-response
                          input-response]])

(require [gently.transfer_function [define-transfer-function
                                    tf
                                    substitute
                                    connect o]])
(require [gently.variable [define
                           documentation
                           doc]])
(require [gently.plot [plot-separately]])
(require [gently.input [step]])
