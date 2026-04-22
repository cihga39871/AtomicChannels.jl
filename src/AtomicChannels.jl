module AtomicChannels

include("AtomicChannel.jl")
export AtomicChannel, AtomicCell, tryput!, trytake!, get!, release!

include("ReusePools.jl")
end
