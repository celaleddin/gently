(defn make-variable [thing]
  """
  Create a new subclass of `(type thing)` and return an instance
  of it if the `thing` is an builtin object. Else, return the
  `thing` itself. This process makes it possible to add new
  attributes (like docstrings) to Python's builtin objects.

  Example:
  >>> (= 5 (variable 5))
  True
  """
  (setv class (type thing))
  (if (= class.--module-- "builtins")
      (do
        (setv class-name class.--name--
              new-class (type class-name (, class) {}))
        (new-class thing))
      thing))


(defclass docstring [str]
  "A string with a non-quoting --repr-- function"
  (defn --repr-- [self] self))

(defmacro set-documentation [symbol docstring]
  "Set documentation string `docstring` for `symbol`"
  `(do
     (import gently.variable)
     (setattr ~symbol "**doc**" (gently.variable.docstring ~docstring))))

(defmacro documentation [symbol]
  "Get the documentation of `symbol`"
  `(getattr ~symbol "**doc**"
            (% "No documentation found for symbol '%s'" (name '~symbol))))


(defmacro/g! define [symbol value &optional docstring]
  "Define a variable"
  `(do
     (import [gently.variable [make-variable :as ~g!make-variable]])
     (require [gently.variable [set-documentation :as ~g!set-documentation]])
     (setv ~symbol (~g!make-variable ~value))
     ~(when docstring
        `(~g!set-documentation ~symbol ~docstring))))
