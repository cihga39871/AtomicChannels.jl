module AtomicChannels

using Base.GC

include("AtomicChannel.jl")
export AtomicChannel, AtomicCell, tryput!, trytake!, get!, release!

include("ReusePool.jl")
export ReusePool, acquire!, release!

end
