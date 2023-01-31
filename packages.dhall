let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.3/packages.dhall
        sha256:ffc496e19c93f211b990f52e63e8c16f31273d4369dbae37c7cf6ea852d4442f

in  upstream
  with halogen-vdom =
        { dependencies =
            [ "bifunctors"
            , "effect"
            , "foreign"
            , "foreign-object"
            , "maybe"
            , "prelude"
            , "refs"
            , "tuples"
            , "unsafe-coerce"
            , "web-html"
            ]
        , repo = "ssh://git@bitbucket.org/juspay/purescript-halogen-vdom.git"
        , version = "v3.0.1"
        }
  with tracker =
        { dependencies =
            [ "effect"
            , "prelude"
            , "presto" 
            , "arrays"
            , "debug"
            , "foldable-traversable"
            , "foreign"
            , "foreign-generic"
            , "foreign-object"
            , "maybe"
            , "strings"
            ]
        , repo = "ssh://git@bitbucket.org/juspay/purescript-tracker.git"
        , version = "v2.0.2"
        }
  with foreign-generic =
      { dependencies =
        [ "arrays"
        , "assert"
        , "bifunctors"
        , "console"
        , "control"
        , "effect"
        , "either"
        , "exceptions"
        , "foldable-traversable"
        , "foreign"
        , "foreign-object"
        , "identity"
        , "lists"
        , "maybe"
        , "newtype"
        , "partial"
        , "prelude"
        , "record"
        , "strings"
        , "transformers"
        , "tuples"
        , "typelevel-prelude"
        , "unsafe-coerce"
        ]
      , repo = "ssh://git@bitbucket.org/juspay/purescript-foreign-generic.git"
      , version = "v12.0.0"
      }
  with presto =
        { dependencies =
            [ "aff"
            , "avar"
            , "datetime"
            , "effect"
            , "either"
            , "exceptions"
            , "exists"
            , "foldable-traversable"
            , "foreign"
            , "foreign-generic"
            , "foreign-object"
            , "free"
            , "identity"
            , "maybe"
            , "newtype"
            , "parallel"
            , "prelude"
            , "record"
            , "transformers"
            , "tuples"
            , "unsafe-coerce" 
            ]
        , repo = "ssh://git@bitbucket.org/juspay/purescript-presto.git"
        , version = "v2.0.1"
        }