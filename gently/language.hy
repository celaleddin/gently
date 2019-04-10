(import [gently.transfer-function [numerator
                                   denominator
                                   sampling-period]])
(import [gently.plot [plot-together
                      plot-separately
                      plot-list]])
(import [gently.input [define-input-signal]])

(require [gently.transfer-function [define-transfer-function
                                    tf
                                    substitute
                                    connect o]])
(require [gently.variable [define
                           documentation]])
(require [gently.input [step
                        ramp
                        parabola
                        sine]])
(require [gently.response [input-response
                           step-response]])
(require [gently.plot [bode-plot
                       nyquist-plot
                       root-locus-plot
                       pole-zero-plot
                       poles
                       zeros]])

(import control)
