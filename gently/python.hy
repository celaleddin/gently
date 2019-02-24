(defn variable [thing]
  """
  Create a new subclass of `(type thing)` and return an
  instance of it. This process makes it possible to add new
  attributes (like docstrings) to Python's builtin objects.

  Example:
  >>> (= 5 (variable 5))
  True
  """
  (setv class (type thing)
        class-name (getattr class "__name__")
        new-class (type class-name (, class) {}))
  (new-class thing))
