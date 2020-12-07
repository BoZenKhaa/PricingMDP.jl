
# Assigning concrete function call to a method saves the function, not the result.

function factorial(n)
    if n>1
        return n*factorial(n-1)
    elseif n==1
        return 1
    end
end

using BenchmarkTools

fn = factorial(15)



special() = factorial(15)
special2() = fn

@benchmark factorial(15)
@benchmark special()
@benchmark special2()