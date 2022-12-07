using Pkg

# Activate test directory
let pkgdir = "./PMDPs.jl"
    Pkg.activate("$pkgdir/test")
    Pkg.develop(path="$pkgdir")
end


# deactivate PMDPs test project
begin
    Pkg.rm("PMDPs")
    Pkg.activate(".")
end

# Run PMDPs tests
let pkgdir = "./PMDPs.jl"
    Pkg.activate("$pkgdir")
    Pkg.test()
end