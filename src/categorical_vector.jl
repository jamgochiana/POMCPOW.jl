type CategoricalVector{T}
    items::Vector{T}
    cdf::Vector{Float64}

    CategoricalVector(item::T, weight::Float64) = new(T[item], Float64[weight])
end

CategoricalVector{T}(item::T, weight::Float64) = CategoricalVector{T}(item, weight)

function insert!{T}(c::CategoricalVector{T}, item::T, weight::Float64)
    push!(c.items, item)
    push!(c.cdf, c.cdf[end]+weight)
end

function rand(rng::AbstractRNG, d::CategoricalVector)
    t = rand(rng)*d.cdf[end]
    large = length(d.cdf) # index of cdf value that is bigger than t
    small = 0 # index of cdf value that is smaller than t
    while large > small + 1
        new = div(small + large, 2)
        if t < d.cdf[new]
            large = new
        else
            small = new
        end
    end
    return d.items[large]
end


#=
function rand(rng::AbstractRNG, d::CategoricalVector)
    t = rand(rng) * d.weight_sum
    i = 1
    cw = d.weights[1]
    while cw < t && i < length(d.weights)
        i += 1
        @inbounds cw += d.weights[i]
    end
    return d.items[i]
end
=#
