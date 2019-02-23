(defn variable [obj]
  (setv class (type obj)
        class-name (getattr class "__name__")
        new-class (type class-name (, class) {}))
  (new-class obj))
