

struct SimHistoryViewer
    pp::PMDPs.PMDPProblem
    trace::SimHistory
end

struct StateViewer
    pp::PMDPs.PMDPProblem
    s::PMDPs.State
end

function Base.show(io::IO,  pw::StateViewer)
    product = PMDPs.product(pw.pp, pw.s)
    product_str = join([v ? "█" : "▒" for v in product])
    print(io, replace(string(pw.s), r"[0-9]*$"=>product_str))
    # print(io, product_str)
end

function Base.show(io::IO, ::MIME"text/plain", sh::SimHistoryViewer)
    for step in sh.trace
        print(io, StateViewer(sh.pp, step.s))
        action = step.a
        budget = step.info.budget
        price = PMDPs.calculate_price(PMDPs.product(sh.pp, step.s), action)

        printfmt(io, " b:{: 6.2f}", budget)
        printfmt(io, " a:{: 6.2f} ({: 6.2f})", action, price)

        if PMDPs.sale_impossible(PMDPs.PMDPg(sh.pp), step.s)
            outcome, color = "🛇", :red
        else
            outcome, color = PMDPs.user_buy(price, budget) ? ("buy", :green) : ("not", :red)
        end

        print(io, " -> ")
        printstyled(io, "$(outcome)"; color=color)
        print(io,"\t")
        try
            printfmt(io, "r:{: 6.2f} ", step.r)
        catch
        end
        print(io, step.sp)
        print(io, "\n")
    end
end