def square (n : Nat) : Nat := n * n

example : square 3 = 9 := rfl

theorem add_zero_example (n : Nat) : n + 0 = n := Nat.add_zero n
