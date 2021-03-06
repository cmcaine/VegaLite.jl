using Test
using VegaLite
using URIParser
using FilePaths
using DataFrames
using VegaDatasets

@testset "Spec" begin

@test @vlplot()(URI("http://www.foo.com/bar.json")).params == vl"""
    {
        "data": {
            "url": "http://www.foo.com/bar.json"
        }
    }
    """.params

@test_throws ArgumentError @vlplot()(5)

df = DataFrame(a=[1.,2.], b=["A", "B"], c=[Date(2000), Date(2001)])

p1 = (df |> @vlplot("line", x=:c, y=:a, color=:b))
p2 = vl"""
{
  "encoding": {
    "x": {
      "field": "c",
      "type": "temporal"
    },
    "color": {
      "field": "b",
      "type": "nominal"
    },
    "y": {
      "field": "a",
      "type": "quantitative"
    }
  },
  "mark": "line"
}
"""

delete!(p1.params, "data")

@test p1.params == p2.params

p3 = DataFrame(a=[1,2,missing], b=[3.,2.,1.]) |> @vlplot(:point, x=:a, y=:b)

p4 = vl"""
{
  "encoding": {
    "x": {
      "field": "a",
      "type": "quantitative"
    },
    "y": {
      "field": "b",
      "type": "quantitative"
    }
  },
  "data": {
    "values": [
      {
        "b": 3.0,
        "a": 1
      },
      {
        "b": 2.0,
        "a": 2
      },
      {
        "b": 1.0,
        "a": null
      }
    ]
  },
  "mark": "point"
}
"""

# @test p3.params == p4.params

p5 = dataset("cars").path |> @vlplot(:point, x=:Miles_per_Gallon, y=:Acceleration)

@test haskey(p5.params["data"],"url")

end
