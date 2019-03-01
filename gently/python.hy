(defn variable [thing]
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
