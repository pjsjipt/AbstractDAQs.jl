
export numstring

"""
`numstring(x, n=2)`

Left pads a number (`x`) with zeros to a total of `n` charaters.

## Example
```julia-repl
julia> numstring(11, 2)
"11"

julia> numstring(11, 3)
"011"

julia> numstring(11, 4)
"0011"
``` 
"""
numstring(x, n=2) = string(10^n + x)[2:end]
