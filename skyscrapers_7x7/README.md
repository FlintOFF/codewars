# 7×7 Skyscrapers

I was very impressed with this task. 
At first glance, it looks very simple, but it's not. 
The main problem is the execution time. 
If we use a brute-force approach to try all possible variants, it would take a very long time.
The current solution does this in fractions of a second, on average in **0.1 seconds**.

It works with different Skyscrapers sizes (4×4, 6×6, 7×7).

This task actually motivated me to create this repository.

All the information can be found at the original [source link](https://www.codewars.com/kata/5917a2205ffc30ec3a0000a8/ruby).

## How to use

* To run `ruby run.rb`. Typical output is
```bash
Puzzle #1 (4×4) was solved in 0.00203 seconds
Puzzle #2 (4×4) was solved in 0.001241 seconds
Puzzle #3 (6×6) was solved in 0.018298 seconds
Puzzle #4 (6×6) was solved in 0.022128 seconds
Puzzle #5 (6×6) was solved in 0.022489 seconds
Puzzle #6 (7×7) was solved in 0.140705 seconds
Puzzle #7 (7×7) was solved in 0.148137 seconds
Puzzle #8 (7×7) was solved in 0.150471 seconds
Puzzle #9 (7×7) was solved in 0.13702 seconds
Total time is 0.642796 seconds
```
* To test `rspec skyscrapers_spec.rb`
* The main code in the file `skyscrapers.rb`
