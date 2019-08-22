;;;; Naming a value with a symbol
(define a-variable 24 "This is a sample definition")

;;;; Transfer function definition
(define-transfer-function a-system
  "A transfer function representing a second-order system"
  (numerator ωn^2)
  (denominator s^2 + 2*ζ*ωn*s + ωn^2))

;;;; Getting information about transfer functions
(numerator a-system)
(denominator a-system)
(sampling-period a-system)

;;;; Accessing documentation strings
(documentation a-system)
(documentation a-variable)

;;;; Substituting free symbols of transfer functions with values
(define substituted-system (substitute a-system (ωn 8 ζ 0.8)))

;;;; A shorthand for expressing short and non-symbolic transfer functions
#tf(100)
(define integrator #tf(1/s))

;;;; Input signal expressions (and their optional parameters)
#step()      ;; #step(start-time end-time amplitude)
#ramp()      ;; #ramp(start-time end-time slope)
#parabola()  ;; #parabola(start-time end-time)
#sine()      ;; #sine(start-time end-time)

;;;; Poles and zeros of a transfer function
(poles substituted-system)
(zeros substituted-system)

;;;; Various plotting operators
(bode-plot substituted-system)
(nyquist-plot substituted-system)
(root-locus-plot substituted-system)
(pole-zero-plot substituted-system)

;;;; Evaluating system responses
(input-response #step() substituted-system)
(step-response substituted-system)

;;;; Plotting system responses and input signals
(plot-together
  (step-response substituted-system)
  #step())

(plot-separately
  (input-response #sine() substituted-system)
  (input-response #ramp() substituted-system))

(plot-separately
  (together
    (input-response #sine() substituted-system)
    #sine())
  (together
    (input-response #ramp() substituted-system)
    #ramp()))

;;;; Block diagram representations and system interconnections
(o
  (> #tf(10) substituted-system)
  (^ #tf(1)))
(o
  (> #tf(10)
     (o (> #tf(20)) (> #tf(20)))
     substituted-system)
  (^ #tf(10))) ;; it is possible to use +^ for positive feedback,
               ;; and -^ for explicit negative feedback.
               ;; default feedback type for ^ is negative feedback.
