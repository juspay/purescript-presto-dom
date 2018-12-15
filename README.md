# Presto DOM

UI Framework for writing cross platform native apps.

## Quickstart

You can get your hands dirty by building a login form using Presto DOM

```
git clone https://bitbucket.org/juspay/purescript-presto-dom.git
cd examples/login-form
npm i
bower i
npm start
```

Open http://localhost:8080/dist/ in your browser.

See [examples](https://bitbucket.org/juspay/purescript-presto-dom/tree/master/examples/) directory for more samples.


## Add PrestoDOM to your existing project

```
bower i purescript-presto-dom
```

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for details.



# PrestoDOM Details

A type-safe, run anywhere UI library in PureScript built on top of [purescript-halogen-vdom](https://github.com/slamdata/purescript-halogen-vdom).

## Architecture

PrestoDOM follows the Elm architecture which is basically a combination of the following specific parts:

* Initial State: the initial state
* Eval: a way to update our state
* View: a way to view our state as HTML
* Screen: an object encapsulating all the other 3 above

You can read more about the Elm architecture [here.](https://guide.elm-lang.org/architecture/)

![](/assets/Screen Shot 2018-04-26 at 19.17.25.png)

A simple pattern looks like the following:

```haskell
type State = {...}

initialState :: State
initialState = {...}

data Action = A | B

eval :: Action -> State -> Either Action State
eval A state = Right state
eval B state = Left B

view :: forall i w eff. (Action -> Eff (frp :: FRP | eff) Unit) -> State -> PrestoDOM Action w
view push state =
  linearLayout
  [] []

screen =
  { initialState
  , view
  , eval
  }
```




