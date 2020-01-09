using JSON
using Serialization
include("utils.jl")


datapath = "../data"

param = JSON.parsefile("../hyper-parameters.json")
regionps = param["region"]
cityname = regionps["cityname"]
cellsize = regionps["cellsize"]

region = SpatialRegion(cityname,
                       regionps["minlon"], regionps["minlat"],
                       regionps["maxlon"], regionps["maxlat"],
                       cellsize, cellsize,
                       regionps["minfreq"], # minfreq
                       40_000, # maxvocab_size
                       10, # k
                       4)

println("Building spatial region with:
        cityname=$(region.name),
        minlon=$(region.minlon),
        minlat=$(region.minlat),
        maxlon=$(region.maxlon),
        maxlat=$(region.maxlat),
        xstep=$(region.xstep),
        ystep=$(region.ystep),
        minfreq=$(region.minfreq)")

paramfile = "$datapath/$(region.name)-param-cell$(Int(cellsize))"
if isfile(paramfile)
    println("Reading parameter file from $paramfile")
    region = deserialize(paramfile)
    println("Loaded $paramfile into region")
else
    println("Cannot find $paramfile")
end


do_split = false
start = regionps["train_size"] + regionps["eval_size"] + 1
num_query = regionps["test_size"]
num_db = 0
querydbfile = joinpath(datapath, "querydb.h5")
tfile = joinpath(datapath, "trj.t")
labelfile = joinpath(datapath, "trj.label")
vecfile = joinpath(datapath, "trj.h5")

createQueryDB("$datapath/$cityname.h5", start, num_query, num_db,
              (x, y)->(x, y),
              (x, y)->(x, y);
              do_split=do_split,
              querydbfile=querydbfile)
createTLabel(region, querydbfile; tfile=tfile, labelfile=labelfile)
