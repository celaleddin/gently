(import [gently.transfer-function [numerator
                                   denominator
                                   sampling-period]])
(import [gently.plot [plot-together
                      plot-separately
                      plot-list]])

(require [gently.transfer-function [define-transfer-function
                                    tf
                                    substitute
                                    connect o]])
(require [gently.variable [define
                           documentation]])
(require [gently.input [step]])
(require [gently.response [input-response
                           step-response]])
