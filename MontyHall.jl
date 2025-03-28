using Pkg; Pkg.activate(".")
# BLAS.set_num_threads(1)

using Random, Statistics
Random.seed!(1)

function whichDoor_Rstyle(👈; nds=3)
    🚪 = collect(1:nds)
    🚗 = rand(🚪)
    if 👈 == 🚗
        💁 = rand(setdiff(🚪, 👈))
    else
        💁 = rand(setdiff(🚪, [👈, 🚗]))
    end
    👌 = rand(setdiff(🚪, [👈, 💁]))
    return 👈, 🚗, 👌, 💁
end

function countMTH_fill(n, whichDoor::Function; nds=3)
    games = Matrix{Int64}(undef, 4, n)
    for i in 1:n
        games[:,i] .= whichDoor(1, nds=nds)
    end
    open3 = games[4,:] .== 3
    open3games = games[:, open3]
    mean(open3games[1,:] .== open3games[2,:]),
    mean(open3games[3,:] .== open3games[2,:])
end

@time countMTH_fill(1, whichDoor_Rstyle)
@time countMTH_fill(10^6, whichDoor_Rstyle)

function countMTH_fill_Parallel(n, whichDoor::Function; nds=3)
    games = Matrix{Int64}(undef, 4, n)
    Threads.@threads for i in 1:n
        games[:,i] .= whichDoor(1, nds=nds)
    end
    open3 = games[4,:] .== 3
    open3games = games[:, open3]
    mean(open3games[1,:] .== open3games[2,:]),
    mean(open3games[3,:] .== open3games[2,:])
end

@time countMTH_fill_Parallel(1, whichDoor_Rstyle)
@time countMTH_fill_Parallel(10^6, whichDoor_Rstyle)

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
    return 👈, 🚗, 👌, 💁
end

@time countMTH_fill(1, whichDoor)
@time countMTH_fill(10^6, whichDoor)
@time countMTH_fill_Parallel(10^6, whichDoor)

function countMTH(n, whichDoor::Function; nds=3)
    n_keep, n_switch, n_open3 = 0, 0, 0
    for i in 1:n
        game = whichDoor(1, nds=nds)
        if game[4] == 3
            n_open3 += 1
            if game[1] == game[2]
                n_keep += 1
            elseif game[3] == game[2]
                n_switch += 1
            end
        end
    end
    return (n_keep, n_switch) ./ n_open3
end

@time countMTH(1, whichDoor)
@time countMTH(10^6, whichDoor)

# be careful of data races

mutable struct Counter
    @atomic n_keep::Int
    @atomic n_switch::Int
    @atomic n_open3::Int
end

function countMTH_ct(n, whichDoor::Function; nds=3)
    c = Counter(0, 0, 0)
    Threads.@threads for i in 1:n
        game = whichDoor(1, nds=nds)
        if game[4] == 3
            @atomic c.n_open3 += 1
            if game[1] == game[2]
                @atomic c.n_keep += 1
            elseif game[3] == game[2]
                @atomic c.n_switch += 1
            end
        end
    end
    return (c.n_keep, c.n_switch) ./ c.n_open3
end

@time countMTH_ct(1, whichDoor)
Random.seed!(1); @time countMTH_ct(10^6, whichDoor)

function countMTH_mt(n, whichDoor::Function; nds=3)
    n_keep = Threads.Atomic{Int}(0)
    n_switch = Threads.Atomic{Int}(0)
    n_open3 = Threads.Atomic{Int}(0)
    Threads.@threads for i in 1:n
        game = whichDoor(1, nds=nds)
        if game[4] == 3
            Threads.atomic_add!(n_open3, 1)
            if game[1] == game[2]
                Threads.atomic_add!(n_keep, 1)
            elseif game[3] == game[2]
                Threads.atomic_add!(n_switch, 1)
            end
        end
    end
    return (n_keep[], n_switch[]) ./ n_open3[]
end

@time countMTH_mt(1, whichDoor)
Random.seed!(1); @time countMTH_mt(10^6, whichDoor)

# Summary

using Chairmarks

@be countMTH_fill(10^6, whichDoor_Rstyle)
@be countMTH_fill_Parallel(10^6, whichDoor_Rstyle)

@be countMTH_fill(10^6, whichDoor)
@be countMTH_fill_Parallel(10^6, whichDoor)

@be countMTH(10^6, whichDoor)

@be countMTH_ct(10^6, whichDoor)

@be countMTH_mt(10^6, whichDoor)

# using BenchmarkTools
# @benchmark countMTH_fill(10^6, whichDoor_Rstyle)
# @benchmark countMTH_fill_Parallel(10^6, whichDoor_Rstyle)

# @benchmark countMTH_fill(10^6, whichDoor)
# @benchmark countMTH_fill_Parallel(10^6, whichDoor)

# @benchmark countMTH(10^6, whichDoor)

# @benchmark countMTH_ct(10^6, whichDoor)

# @benchmark countMTH_mt(10^6, whichDoor)

