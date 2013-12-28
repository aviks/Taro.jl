# Taro

Taro is an utility belt of functions to work with document files in Julia. It uses [Apache Tika](http://tika.apache.org/) and [Apache POI](http://poi.apache.org) (via [JavaCall](http://aviks.github.io/JavaCall.jl/)) to process the files. Current functionality includes the ability to extract text and metadata from a wide variety of document formats. Coming soon is the ability to read a DataFrame off an Excel sheet. 

##Usage

```julia
using Toro
Toro.init()
```

##API

`Toro.extract(filename::String)`

The extract function retrieves document metadata and the body text of a document. It returns a Dict of metadata name value pairs, and a String with the text of the document. Supported formats include MS Office, Open Office and PDF documents. 


[![Build Status](https://travis-ci.org/aviks/Taro.jl.png)](https://travis-ci.org/aviks/Taro.jl)
