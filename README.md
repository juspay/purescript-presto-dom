# Presto DOM

UI Framework for writing cross platform native apps.

# What is it? 

Presto-DOM is a react like framework. 

It provides a DSL - a bunch of platform independent functions to construct UI.
Evalation of these functions lead to creation of a JavaScript Object. 

This JavaScript Object is used by an another project `presto-ui`. 
`presto-ui` reads the object and depending on the platform does the rendering. 

PrestoDOM communicates with `presto-ui` for rendering to screen. 

In most simpler terms, PrestoDOM does the following

1. transformation (PrestoDSL (Halogen-VDOM)) --> PrestoUI DSL 
2. invoking PrestoUI
3. diffing algorithm to reduce DOM updates ( granular calling of PrestoUI API)
4. one way caching. 

## Quickstart


You can look for more documentation and example at 

[prestdom-example](https://bitbucket.org/juspay/prestodom-example/src/master/) repository. 


## Add PrestoDOM to your existing project

```
bower i purescript-presto-dom
```

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for details.
