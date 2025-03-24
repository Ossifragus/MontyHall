using Pkg; Pkg.activate(".")

using Random; Random.seed!(1)

function whichDoor_badcode(👈; nds=3)
    🚪 = fill("🐐", nds)
    🚗 = rand(1:nds)
    🚪[🚗] = "🚗"
    if 🚪[👈] == "🚗"
        💁 = rand(setdiff(1:nds, 👈))
    else
        💁 = rand(setdiff(1:nds, [👈, 🚗]))
    end
    👌 = rand(setdiff(1:nds, [👈, 💁]))
    return (👈=👈, 🚗=🚗, 👌=👌, 💁=💁)
end

@time whichDoor_badcode(rand(1:3), nds=3)

function whichDoor(👈; nds=3)
    🚪 = collect(1:nds)
    🚗 = rand(🚪)
    deleteat!(🚪, 👈)
    if 👈 == 🚗
        💁 = rand(1:length(🚪))
        💁 = popat!(🚪, 💁)
    else
        deleteat!(🚪, 🚗 - (🚗 > 👈))
        💁 = rand(1:length(🚪))
        💁 = popat!(🚪, 💁)
        push!(🚪, 🚗)
    end
    👌 = rand(🚪)
    return (👈=👈, 🚗=🚗, 👌=👌, 💁=💁)
end

@time whichDoor(rand(1:3), nds=3)

function countMTH(n, whichDoor::Function; nds=3)
    n_keep, n_switch = 0, 0
    for i in 1:n
        game = whichDoor(3, nds=nds)
        if game.👈 == game.🚗
            n_keep += 1
        elseif game.👌 == game.🚗
            n_switch += 1
        end
    end
    return (n_keep, n_switch) ./ n
end

@time countMTH(1000000, whichDoor_badcode)

using FLoops
function countMTHfloop(n, whichDoor::Function; nds=3, nt=Threads.nthreads())
    @floop ThreadedEx(basesize=n÷nt) for i in 1:n
        game = whichDoor(3, nds=nds)
        if game.👈 == game.🚗
            @reduce n_keep += 1
        elseif game.👌 == game.🚗
            @reduce n_switch += 1
        end
    end
    return (n_keep, n_switch) ./ n
end

@time countMTHfloop(1000, whichDoor_badcode)

using BenchmarkTools

function whichDoor2(👈; nds=3)
    🚪 = collect(1:nds)
    🚗 = rand(🚪)
    deleteat!(🚪, 👈)
    if 👈 == 🚗
        💁 = popat!(🚪, rand(eachindex(🚪)))
    else
        deleteat!(🚪, 🚗 - (🚗 > 👈))
        💁 = popat!(🚪, rand(eachindex(🚪)))
        push!(🚪, 🚗)
    end
    👌 = rand(🚪)
    return (👈=👈, 🚗=🚗, 👌=👌, 💁=💁)
end

@time countMTH(1000000, whichDoor_badcode)
@time countMTH(1000000, whichDoor)
@time countMTH(1000000, whichDoor2)

@time countMTHfloop(1000000, whichDoor_badcode)
@time countMTHfloop(1000000, whichDoor)

